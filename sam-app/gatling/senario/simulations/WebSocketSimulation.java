import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;

import java.time.Duration;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;
import java.util.function.Supplier;
import java.util.stream.Stream;

public class WebSocketSimulation extends Simulation {

  String WS_HOST = System.getenv("WS_HOST");

  Iterator<Map<String, Object>> feeder = Stream.generate((Supplier<Map<String, Object>>) () -> {
    String userId = UUID.randomUUID().toString();
    return Collections.singletonMap("userId", userId);
  }).iterator();

  HttpProtocolBuilder httpProtocol = http
      .baseUrl("http://" + WS_HOST)
      .disableWarmUp()
      .contentTypeHeader("application/json")
      .wsBaseUrl("ws://" + WS_HOST);

  // A scenario is a chain of requests and pauses
  ScenarioBuilder scn = scenario("Chat")
      .feed(feeder)
      .exec(
          ws("Connect WS")
              .connect("/socket/websocket?token=undefined&vsn=2.0.0"))
      .exec(
          ws("WS EchoBack")
              .sendText("[\"3\", \"3\", \"room:lobby\", \"phx_join\", {\"user_name\": \"#{userId}\"}]"))
      .repeat(120).on(
          exec(
              ws("WS EchoBack")
                  .sendText("[\"3\", \"4\", \"room:lobby\", \"new_msg\", {\"msg\": \"hello\"}]"))
              .pause(Duration.ofMillis(500)))
      .exec(ws("Close WS").close());

  {
    setUp(scn.injectOpen(atOnceUsers(1000)).protocols(httpProtocol));
  }
}
