# bookish-guacamole

# Overview
Bookish Guacomole deploys a basic analytics microservice using AWS Lambda, SNS and DynamoDB. `service.yaml` contains the full CloudFormation required in deploying the microservice to AWS.

# Table of Contents
* [Overview](#overview)
* [Service Requirements](#service-requirements)
  * [Event Schema](#event-schema)
    * [Received Message Event](#received-message-event)
    * [Weekly Message Event](#weekly-message-event)
    * [Success Rate Event](#success-rate-event)
  * [Assumptions](#assumptions)
* [Soltion Documentation](#solution-documentation)
  * [Architecture](#architecture)
  * [DynamoDB Schema](#dynamodb-schema)
  * [Design Considerations](#design-considerations)
  * [Future Roadmap](#future-roadmap)
* [Testing](#testing)

# Service Requirements

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
SNSTopic Name: `recv_message`

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
SNSTopic Name: `weekly_diagnostic`

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

Generated on an update to the table `weekly_diagnostic`, within the DynamoDB. See [DynamoDB Schema](#dynamodb-schema).
SNSTopic Name: `success_rate`

## Assumptions 
  * The success rate to publish to the SNS topic `success_rate` is calculated across the full time since module reset. 
  * The success rate event will be published on all new `weekly_diagnostic` events (see [Design Considerations](#design-considerations) for reasoning).


# Solution Documentation
## Architecture
![Infrastructure Architecture](architecturediagram.png)
  The above diagram outlines the design for the service. Amazon SNS is used as the messaging service within the event-driven architecture. AWS Lambdas are used as the underlying compute for the service, and are both consumers and produces of messages from the various events (see above for event schema and naming). DynamoDB is used as a mock data lake (for need of rapid development) for the service. This choice is for two reasons: namely the prior mentioned rapid development, and DynamoDB's event triggers. 

## DynamoDB Schema 

Table: `message_recv`
  Primary Key (composite): 
    * Partition Key: `moduleId`
    * Sort Key: `timestamp`
  
  Attributes:
    * `moduleId`: string, S
    * `timestamp`: int, N

Table: `weekly_diagnostic`
   Primary Key (composite): 
    * Partition Key: `moduleId`
    * Sort Key: `timestamp`
  
  Attributes:
    * `moduleId`: string, S
    * `timestamp`: int, N
    * `attempts`: int, N


## Design Considerations
 * The decision to trigger the success rate based off the weekly diagnostic is for two reasons (and for lack of strict requirement). Firstly, more frequent updates will be incorrect and/or require data remediation. Consider `message_recv` events for a module with a timestamp after the module's most recent `weekly_diagnostic`. Aggregating such successful messages will bias the success rate (hence incorrect), and depending on the use of the `success_rate` events, other microservices will require data remediation (once a new `weekly_diagnostic` for the module arrives). 
 * DynamoDB is not a suitable for a full analytics system. It is intended as a mock datastore for the remaining decisions about the service. 
 * Except to create tables easily queriable by moduleID (the current main use case), little schema design has been considered.

## Future Roadmap 

# Testing 

To test the `mesg_recv` lambda: 
```
aws sns publish --topic-arn=<MESG-RECV-ARN> --message '{"moduleid": "iAmAModule", "timestamp": 1234567890}'
```

To test the 'weekly_diagnostic` lambda: 
```
aws sns publish --topic-arn=<WEEKLY-DIAGNOSTIC-ARN> --message '{"moduleid": "iAmAModule", "timestamp": 9876543210, "attempts": 42}'
```





