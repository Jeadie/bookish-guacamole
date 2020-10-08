# bookish-guacamole

# Overview
TODO

# Service Requirements
## Assumptions 
  * Not considering the unsuccessful messages that have been attempted since the most recent, weekly diagnostic event. In practice, this will lead to a spiked estimate of success such that, after each weekly event, the success rate will be an overestimate of the success rate until the next weekly event corrects for this (lowering the success rate to its true value). It was chosen to not use a forecast of the previous success rate to compensate (e.g. a uniform number of unsuccessful message based on the prior weekly diagnostic) as this would poison the the accuracy of data created by the service that would need data remediation See [Design Considerations](#design-considerations) for discussion on alternatives.
  * Success rate is calculated across all time. 


## Event schema

### Received Message Event
Payload: 
```
 {
  "moduleId": <string>,
  "timestamp": <uint64_t>
 }
```
Where: 
 * `moduleId`: is the unique identifier of a module. 
 * `tx_attempts`: is the cumulative count since the module was reset
Generated for every message received, successfully, from an IoT device. 

### Weekly Message Event 
```
 {
   “moduleid”: <string>,
   “timestamp”: <uint64_t>,
   “attempts”: <uint32_t>
 }
```
Where:
 * `moduleid`: unique identifier of a module
 * `timestamp`: a unix timestamp (1/1/1970)
 * `attempts`: the cumulative count of attempted message transmissions since the module was reset
Generated on a time scheduled basis, weekly. 

### Success Rate Event
```
 {
   “moduleid”: <string>,
   “timestamp”: <uint64_t>,
   “success_rate”: <float>
 }
```
Where:
 * `moduleid`: unique identifier of a module
 * `timestamp`: a unix timestamp (1/1/1970)
 * `success_rate`: the percentage attempted message transmissions which have been successfully received

Generated on an update to the table ``, within the DynamoDB. See [DynamoDB Schema](#dynamodb-schema).  

# Solution Documentation
## Architecture
![Infrastructure Architecture](architecture-diagram.png)
## DynamoDB Schema 

## Design Considerations
* As mentioned in assumptions, the success rate is calculated using message received events that are more recent than the most recent weekly message event. This is a stream-based design. A batch solution would process, like the weekly message event, on a timed schedule. In this example service, a 
* Use DynamoD
