import java.net.URI;
import java.net.http.*;
import java.time.Duration;
public class HealthCheck {
    public static void main(String[] args) throws Exception {
        String port = System.getenv().getOrDefault("PORT", "8080");
        var client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
        var request = HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + "/health"))
            .timeout(Duration.ofSeconds(3)).GET().build();
        System.exit(client.send(request, HttpResponse.BodyHandlers.discarding()).statusCode() == 200 ? 0 : 1);
    }
}
