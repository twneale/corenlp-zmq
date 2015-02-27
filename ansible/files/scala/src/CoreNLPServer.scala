import java.util.Properties
import java.io.{ByteArrayOutputStream}

import scala.sys

import edu.stanford.nlp.pipeline.Annotation
import edu.stanford.nlp.pipeline.StanfordCoreNLP
import edu.stanford.nlp.trees.Tree
import edu.stanford.nlp.trees.TreeCoreAnnotations.TreeAnnotation
import edu.stanford.nlp.ling.CoreAnnotations.SentencesAnnotation

import org.zeromq.ZMQ
import org.zeromq.ZMQ.{Context,Socket}

import play.api.libs.json._


class Parser(annotators: String) {
  var props = new Properties
  props.setProperty("annotators", annotators)
  println("Loading CoreNLP annotators: " + annotators)
  println("Loading CoreNLP...")
  var pipeline = new StanfordCoreNLP(props)
  println("...done loading annotators.")

  def getXML(sentence: String): String = {
    val document = new Annotation(sentence)
    pipeline.annotate(document)
    var output_stream = new ByteArrayOutputStream
    pipeline.xmlPrint(document, output_stream)
    return output_stream.toString("utf8");
  }
}

object CoreNLPServer extends Application {
  println("CoreNLPServer")
  val context = ZMQ.context(1)
  val broker_host = scala.sys.env.getOrElse("CORENLP_BROKER_HOST", "localhost")
  val broker_port = scala.sys.env.getOrElse("CORENLP_BROKER_PORT", "5560")
  val broker_string = "tcp://%s:%s".format(broker_host, broker_port)

  println("Connecting to broker at: %s".format(broker_string))
  val receiver = context.socket(ZMQ.REP)
  receiver.connect(broker_string)
  println("Serving....")

  val cache = collection.mutable.Map[String, Parser]()
  def newParser(annotators: String) = new Parser(annotators)
  def getParser(ann: String) = cache.getOrElseUpdate(ann, newParser(ann)
)
  while (true) {
    val json_text = receiver.recvStr()
    val json = Json.parse(json_text)
    val annotators = (json \ "annotators").as[String]
    val text = (json \ "text").as[String]
    val parser = getParser(annotators)
    val result = parser.getXML(text)
    val resultJson: JsValue = JsObject(Seq(
      "xml" -> JsString(result),
      "annotators" -> JsString(annotators)
    ))      
    receiver.send(resultJson.toString())
  }
}
