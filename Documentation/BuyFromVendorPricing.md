Suave has several vendors with the same Parent Vendor. When purchases are created the child vendor is the buy-from and the parent vendor is the pay-to. When purchase lines are created, suave would like the child vendor pricing to be used insead of the parent vendor. 

When a purchase document is created, and the pay-to is not the buy-from vendor:

New field added to the Vendor table/card 'SBC Use Buy-From Pricing'
New event added 'PurchPriceCalcMgtOnBeforePurchLinePriceExists'
- Logic will use the Buy-From Vendor No. to pull the pricing from the Purchase Price table
--Suave does not use the Price List.