package com.urdnot.spark

import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}
import org.apache.spark.streaming._
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010._
import play.api.libs.json._


/**
  * Created by jsewell on 6/22/17.
  */
object temperatureProcessing {


  case class temperatureClassRaw(
                               dateTime: String,
                               tempF: Double,
                               host: String)
  case class temperatureClassFormatted(
                                  dateTime: org.joda.time.DateTime,
                                  tempF: Double,
                                  host: String)

  /*
  create keyspace home_sensors WITH replication = {'class':'SimpleStrategy', 'replication_factor': 1};
  CREATE TABLE home_sensors.temperatures (dateTime text, host text, tempF double, PRIMARY KEY (dateTime));
  CREATE TABLE home_sensors.temperatures (
    datetime text,
    host text,
    tempf double,
    PRIMARY KEY (datetime));
*/
  implicit val teperatureClassFormat = Json.format[temperatureClassRaw]
  def main(args: Array[String]): Unit = {

    val sparkClusterName = "Urdnot Cluster"
    val cassandraHostIP = "spark01"
    val Array(zkQuorum, group, rawTopics, numThreads) = args
    val topics: Array[String] = rawTopics.split(",")
    val conf = new SparkConf().setMaster("local[*]").setAppName("temperature sensors").set("spark.cassandra.connection.host", "192.168.152.120,192.168.152.4,192.168.152.122").set("spark.cassandra.connection.port", "9042")
    val ssc = new StreamingContext(conf, Seconds(2))
    ssc.sparkContext.setLogLevel("ERROR")

    val kafkaParams = Map[String, Object](
      "bootstrap.servers" -> zkQuorum,
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "group.id" -> group,
      "auto.offset.reset" -> "latest",
      "enable.auto.commit" -> (false: java.lang.Boolean)
    )
    val stream = KafkaUtils.createDirectStream[String, String](
      ssc,
      PreferConsistent,
      Subscribe[String, String](topics, kafkaParams)
    )
    stream.foreachRDD(parseTemp(_))
    ssc.start()
    ssc.awaitTermination()
  }
  def parseTemp(jsonRecord: RDD[ConsumerRecord[String, String]]) = {
    val spark = SparkSession.builder.config(jsonRecord.sparkContext.getConf).getOrCreate()
    val data = spark.createDataFrame(jsonRecord.map(x => Json.parse(x.value().replace("\'", "\"")).as[temperatureClassRaw])) //Kafka puts everything in single quotes
    import org.apache.spark.sql.functions.unix_timestamp
    val formattedTemp = data.withColumn("dateTime", unix_timestamp(data("dateTime"), "MM/dd/yy HH:mm:ss").cast("timestamp"))
    //df.withColumn("ts", ts).show(2, false)
    processTemp(formattedTemp.withColumnRenamed("tempF", "tempf").withColumnRenamed("dateTime", "datetime"))
  }
  def processTemp(recordData: DataFrame): Unit = {
    recordData.write.format("org.apache.spark.sql.cassandra").mode(SaveMode.Append).options(Map("table" -> "temperatures", "keyspace" -> "home_sensors")).save()//.options(table="othertable", keyspace = "ks").save(mode ="append")
  }
}
