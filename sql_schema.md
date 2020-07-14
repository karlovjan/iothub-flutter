# Sql database schema

Each iot hub owns local database - connection string

Tables
 - sensor
 - measurement
 - measured_property
  
  
Relations
- sensor to measured_property - one-to-many
- measured_property to sensor - one-to-many
- sensor to measurement - one-to-many
- measurement to sensor - one-to-one
- measurement to measured_property - one-to-many
- measured_property to measurement - one-to-many
