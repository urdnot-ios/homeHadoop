package com.urdnot.spark

import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming._
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010._
import play.api.libs.json._

/**
  * Created by jsewell on 6/22/17.
  */
object temperatureProcessing {
  case class temperatureClass(
                               dateTime: String,
                               tempF: Double,
                               host: String)
  implicit val teperatureClassFormat = Json.format[temperatureClass]
  def main(args: Array[String]): Unit = {

    val Array(zkQuorum, group, rawTopics, numThreads) = args
    val topics: Array[String] = rawTopics.split(",")
    val conf = new SparkConf().setMaster("local[*]").setAppName("temperature sensors")
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
    val parsed = stream.foreachRDD(parseTemp(_))

    ssc.start()
    ssc.awaitTermination()
    println(parsed)
  }
  def parseTemp(jsonRecord: RDD[ConsumerRecord[String, String]]): Unit = {
    val cleanRecord = jsonRecord.map(x => Json.parse(x.value().replace("\'", "\"")).as[temperatureClass]) //Kafka puts everything in single quotes
    cleanRecord.foreach(println(_))
    println()
  }
  def processTemp(recordData: Any): Unit = {
    println(recordData)
  }
}
