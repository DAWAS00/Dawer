// Core enumerations used by the Order data model.
//
// These live in their own file so they can be imported by callers that do not
// need the full Order class (e.g. form widgets, filters, chat VM).

enum OrderType { pickup, collection, collectionSale }

enum OrderStatus { pending, accepted, inTransit, completed, cancelled }

enum PickupTarget { company, riderBuy }

enum WasteType {
  paper,
  plastic,
  metal,
  glass,
  electronics,
  organic,
  textile,
  wood,
  rubber,
  oil,
  chemicals,
  batteries,
  furniture,
  tires,
  construction,
}

enum WasteForm { solid, liquid, mixed }

enum PaymentModel { perKg, flatFee }

enum WeightCategory { light, medium, heavy, veryHeavy }

enum CollectionDeliveryMethod { selfDelivery, assignRider }

enum CollectionTransactionType { donate, sell }
