cd "C:\Program Files\Microsoft Data Migration Assistant"

.\DmaCmd.exe /Action=SkuRecommendation `
/SkuRecommendationInputDataFilePath="C:\temp\DMA\counters.csv" `
/SkuRecommendationTsvOutputResultsFilePath="C:\temp\DMA\prices_offline.tsv" `
/SkuRecommendationJsonOutputResultsFilePath="C:\temp\DMA\prices_offline.json" `
/SkuRecommendationOutputResultsFilePath="C:\temp\DMA\prices_offline.html" `
/SkuRecommendationPreventPriceRefresh=true