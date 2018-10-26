cd "C:\Program Files\Microsoft Data Migration Assistant"

.\DmaCmd.exe `
/Action=SkuRecommendation `
/SkuRecommendationInputDataFilePath="C:\temp\DMA\counters.csv" `
/SkuRecommendationTsvOutputResultsFilePath="C:\temp\DMA\prices_online.tsv" `
/SkuRecommendationJsonOutputResultsFilePath="C:\temp\DMA\prices_online.json" `
/SkuRecommendationOutputResultsFilePath="C:\temp\DMA\prices_online.html" `
/SkuRecommendationCurrencyCode=EUR `
/SkuRecommendationOfferName=MS-AZR-0044p  `
/SkuRecommendationRegionName=WestEurope `
/SkuRecommendationSubscriptionId=<subscriptionid> `
/AzureAuthenticationInteractiveAuthentication=true `
/AzureAuthenticationClientId=<clientid> `
/AzureAuthenticationTenantId=<tenantid>