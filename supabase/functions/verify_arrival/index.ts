import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const EARTH_RADIUS_M = 6_371_000
const GEOFENCE_RADIUS_M = 200

function haversineMeters(
  lat1: number, lng1: number,
  lat2: number, lng2: number,
): number {
  const toRad = (d: number) => (d * Math.PI) / 180
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
  return EARTH_RADIUS_M * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405, headers: corsHeaders })
  }

  // Use service role so we can read driver_locations and write fraud_audit
  // regardless of the calling user's JWT.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  let body: {
    orderId?: string
    driverId?: string
    targetLat?: number
    targetLng?: number
  }

  try {
    body = await req.json()
  } catch {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON body' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  const { orderId, driverId, targetLat, targetLng } = body

  if (!orderId || !driverId || targetLat == null || targetLng == null) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields: orderId, driverId, targetLat, targetLng' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  // Read the server-authoritative GPS position.
  // This is what the LocationPublisher streams to Supabase every 10 metres —
  // the client cannot fake this without compromising the service role key.
  const { data: loc, error: locErr } = await supabase
    .from('driver_locations')
    .select('lat, lng, updated_at')
    .eq('driver_id', driverId)
    .eq('order_id', orderId)
    .single()

  if (locErr || !loc) {
    // No server GPS yet (driver just accepted or location service starting up).
    // Return not-allowed so the client retries; do NOT log as fraud.
    return new Response(
      JSON.stringify({ allowed: false, distanceMeters: null, reason: 'no_server_gps' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  const distanceMeters = haversineMeters(loc.lat, loc.lng, targetLat, targetLng)
  const allowed = distanceMeters <= GEOFENCE_RADIUS_M

  if (!allowed) {
    // Log the blocked attempt. Fire-and-forget — don't hold the response.
    supabase
      .from('fraud_audit')
      .insert({
        driver_id: driverId,
        order_id: orderId,
        event_type: 'proximity_block',
        distance_m: distanceMeters,
        driver_lat: loc.lat,
        driver_lng: loc.lng,
        target_lat: targetLat,
        target_lng: targetLng,
      })
      .then(() => {})
  }

  return new Response(
    JSON.stringify({ allowed, distanceMeters: Math.round(distanceMeters) }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
})
