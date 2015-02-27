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


class Parser() {
  var props = new Properties

  val default_annotators = "tokenize,ssplit,pos,lemma,parse"
  val annotators = scala.sys.env.getOrElse(
    "CORENLP_ANNOTATORS", default_annotators)
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

  //var parser = new Parser;
  while (true) {
    val text = receiver.recvStr()
    val json = Json.parse(text)
    println(json)
    //val result = parser.getXML(text)
    receiver.send("{}")
  }
}
