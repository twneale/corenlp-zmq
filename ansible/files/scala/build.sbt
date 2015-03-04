name := "corenlp-zmq"

version := "0.0"

scalaSource in Compile := baseDirectory.value / "src"

resolvers += "Typesafe Repo" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies ++= Seq(
  "edu.stanford.nlp" % "stanford-corenlp" % "3.4",
  "edu.stanford.nlp" % "stanford-corenlp" % "3.4" classifier "models",
  "edu.stanford.nlp" % "stanford-parser" % "3.4",
  "org.zeromq" % "jzmq" % "3.0.1",
  "com.typesafe.play" %% "play-json" % "2.2.1"

)
