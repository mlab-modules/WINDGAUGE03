<!--- PrjInfo ---> <!--- Please remove this line after manually editing --->
<!--- 00a56be08b96043df9e37d6aff7b6990 --->
<!--- Created:2019-04-25 18:04:07.487886: ---> 
<!--- Author:: ---> 
<!--- AuthorEmail:: ---> 
<!--- Tags:: ---> 
<!--- Ust:: ---> 
<!--- Label --->
<!--- ELabel ---> 
<!--- Name:WINDGAUGE03A: --->
# WINDGAUGE03A
<!--- LongName --->
## Venturi tube based anemometer
<!--- ELongName ---> 

<!--- Lead --->
High-endurance venturi anemometer with minimum moving parts. Automatic estimation of direction to magnetic nort. 
<!--- ELead ---> 

<!--- Description --->

![WINDGAUGE03A](doc/img/WINDGAUGE03A.jpg) 

### Advantages
  * Minimised number of moving parts results in increased durability
  * Venturi effect allows accurate measurement in wide range of speeds is especially sensitive for common low airspeeds  

### Function principle

The measuring tube consist an orifice, which increases airflow in the tube. The different speeds generates differentiall preassure, which is measured by electronic differential pressure sensor.  The same principle was used in beginnig of [aircraft airspeed measurement](https://ntrs.nasa.gov/citations/19930091190). It is advantageous due to better sensitivity at lows speeds compared to [pitot-static](https://en.wikipedia.org/wiki/Pitot_tube) tube. 

The anemometer consists the IMU sensor ICM-20948 which contains magnetometer, gyroscopes and accelerometers. The IMU allows sophisticated data aquisition for failure detection and gust wind analysis. 

![WINDGAUGE03A schematics](doc/img/schematics.png) 

### Main parameters
  
  * Absolute azimuth accuracy 1° (to magnetic north)
  * Wind speed measurement range 0-120 km/h
  * Maximum mechanically safe wind speed 150 km/h
  * Communication interfaces: 
    * USB
    * I²C
  * Operational temperature range -20/+45 °C
  * Maximum hail diameter 0.5 cm 

### Software installation 

The anemometer uses [pymlab](https://github.com/MLAB-project/pymlab) software toolkit to interface with a station computer. The toolkit also contains an [example](https://github.com/MLAB-project/pymlab/blob/master/examples/windgauge03a_example.py) which allows basic calibration and data recording of anemometer data. 


#### Usage 

##### Calibration 

Anemometer should be calibrated before the first use. That ensures, calibration of magnetometer parameters. To correctly determine the wind direction by internal magnetometer. 

    python3 serial_logger.py 68  15


<!--- EDescription --->
<!--- Content --->
<!--- EContent --->
<sub><sup> Generated with [MLABweb](https://github.com/MLAB-project/MLABweb). (2019-04-25)</sup></sub>
