with CTE as (
    select dateadd(second, 30, dateadd(minute, datediff(minute, 0, [MDate]), 0)) as [Tradetimeminute], [CommodityId],
	   sum([Qty]) as [TotalQty], sum([Qty] * [Price]) / sum([Qty]) as [AvgPrice]
	from [TX].[dbo].[TradeHty]
	where TradeDate = '20230222' and CommodityId = '00878' and TraderId = 'K36'
	group by dateadd(minute, datediff(minute, 0, [MDate]), 0), [CommodityId]
), CTE2 as (
    select *, cast([TDate] as DATETIME) + CAST([TTime] as DATETIME) as quotetime,
	((MktBid1 - NAVTrade) / NAVTrade) as Bidspd,
	((MktAsk1 - NAVTrade) / NAVTrade) as Askspd
    from [TX].[dbo].[ETFTickData]
    where ETFID = '00878' AND TDate = '20230222'
)
select A.*, B.quotetime, B.NAVBid1, B.NAVAsk1, B.NAVTrade, B.MktBid1, B.MktAsk1, B.MktTrade,
       B.VolumeBid1, B.VolumeAsk1, B.VolumeTrade, B.Bidspd, B.Askspd
from CTE A
cross apply (
    select top 1 *
    from CTE2
    where quotetime <= A.Tradetimeminute AND ETFID = A.CommodityId
    order by quotetime desc) B
