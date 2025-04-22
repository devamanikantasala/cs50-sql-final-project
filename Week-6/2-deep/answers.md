# From the Deep

In this problem, you'll write freeform responses to the questions provided in the specification.

## Random Partitioning

Random Partitioning approach prevents the boats to overloaded with the observations, as they store-up randomly and data distribution is even.
But the main drawback is, for searching specific data requires us to query over all boats, which in turn it makes us having no control over which boat stores which data.


## Partitioning by Hour

Partitioning by hour approach is good for time based searching, like if we search based on hour/time the data could be retreived from the specified boat, and this approach in most cases might lead to un-even data distribution, which further overload the boat with more observations specific to that pariticular time/hour.
Hence, it can be good for time-based queries but on the other hand it can lead to one boat doing all the work.

## Partitioning by Hash Value
Partitioning by Hash Value approach is prevents the boats overloaded with data as hashing using hash function allows evenly data distribution.
This approach is good for when searching for specific observations, as the hash value directs search on specific boats. But the drawback is, it is quiet not a
approach for searching by range as the data might spread across different boats based on hash values.
