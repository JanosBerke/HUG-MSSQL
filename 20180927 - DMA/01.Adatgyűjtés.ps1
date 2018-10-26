# SQL Server 2016 verziótól működik! 
# Perf counter csak itt elérhető, amit használna.
# A gép neve kell mindig, localhost nem megy!
# ha cd/dvd van a gépben, akkor hiba lesz, de jó.

cd "C:\Program Files\Microsoft Data Migration Assistant"

.\SkuRecommendationDataCollectionScript.ps1 `
-ComputerName SQL2016 `
-OutputFilePath C:\temp\DMA\counters.csv `
-CollectionTimeInSeconds 60 `
-DbConnectionString "Server=.;Initial Catalog=master;Integrated Security=SSPI;"