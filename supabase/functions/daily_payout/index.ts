import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Runs at 02:00 AM Amman time (23:00 UTC) via pg_cron.
// For every driver whose balance > 0 and has no active holds,
// records a payout wallet_transaction and resets balance to 0.
//
// pg_cron schedule (run once after deploying this function):
//   SELECT cron.schedule(
//     'daily-payout',
//     '0 23 * * *',
//     $$
//       SELECT net.http_post(
//         url := current_setting('app.supabase_url') || '/functions/v1/daily_payout',
//         headers := jsonb_build_object(
//           'Content-Type', 'application/json',
//           'Authorization', 'Bearer ' || current_setting('app.service_role_key')
//         ),
//         body := '{}'::jsonb
//       )
//     $$
//   );

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Find all drivers with a positive balance and no held amount (no active escrow).
  const { data: wallets, error: walletErr } = await supabase
    .from('driver_wallet')
    .select('driver_id, balance')
    .gt('balance', 0)
    .eq('held_amount', 0)

  if (walletErr) {
    console.error('Failed to fetch wallets:', walletErr.message)
    return new Response(
      JSON.stringify({ error: walletErr.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  if (!wallets || wallets.length === 0) {
    return new Response(
      JSON.stringify({ processed: 0, message: 'No eligible drivers' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }

  let processed = 0
  const errors: string[] = []

  for (const wallet of wallets) {
    const { driver_id, balance } = wallet as { driver_id: string; balance: number }

    // Insert the payout transaction record.
    const { error: txErr } = await supabase
      .from('wallet_transactions')
      .insert({
        driver_id,
        type: 'payout',
        amount: balance,
        note: `Daily payout — ${new Date().toISOString().slice(0, 10)}`,
      })

    if (txErr) {
      errors.push(`driver ${driver_id}: ${txErr.message}`)
      continue
    }

    // Reset balance to 0 after recording the payout.
    const { error: resetErr } = await supabase
      .from('driver_wallet')
      .update({ balance: 0 })
      .eq('driver_id', driver_id)

    if (resetErr) {
      errors.push(`driver ${driver_id} balance reset: ${resetErr.message}`)
      continue
    }

    // Send push notification via the notifications table (picked up by FCM worker).
    await supabase
      .from('notifications')
      .insert({
        user_id: driver_id,
        title: 'تم تحويل أرباحك',
        body: `تم تحويل ${balance.toFixed(3)} د.أ إلى حسابك.`,
        type: 'payout',
      })

    processed++
  }

  const status = errors.length > 0 && processed === 0 ? 500 : 200
  return new Response(
    JSON.stringify({ processed, errors: errors.length > 0 ? errors : undefined }),
    { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
})
