-- Automatic Item Selling
if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Events";
end;

Labs=Labs or {};
function Labs.Merchant()
    Merchant={
        sellRules={},
        stockRules={}
    };

    Merchant.SellRule=Curry(Lists.InsertFunction, Merchant.sellRules);
    Merchant.StockRule=Curry(Lists.InsertFunction, Merchant.stockRules);

    Events.MERCHANT_SHOW(function()
        local total=0;
        for bag=0,4 do
            for slot=1,GetContainerNumSlots(bag) do
                local sell;
                for i=1,#Merchant.sellRules do
                    local r=Merchant.sellRules[i](bag, slot);
                    if r==true then
                        sell=true;
                    elseif r==false then
                        sell=false;
                        break;
                    end;
                end;
                if sell then
                    local q=select(2, GetContainerItemInfo(bag, slot));
                    local price=select(11, GetItemInfo(link));
                    total=total+(q*price);
                    UseContainerItem(bag, slot);
                    print('Selling:', GetContainerItemLink(bag, slot));
                end;
            end;
        end;
    end);

    Events.MERCHANT_SHOW(function()
        for i=1,GetMerchantNumItems() do
            for j=1,#Merchant.stockRules do
                local q=Merchant.stockRules[j](GetMerchantItemInfo(i));
                local current=GetItemCount(GetMerchantItemLink(i));
                if q >= current then
                    BuyMerchantItem(i, math.floor((q - current)/q));
                end;
            end;
        end;
    end);
end;
