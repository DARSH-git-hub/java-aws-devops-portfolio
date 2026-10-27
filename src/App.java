import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;

/** Small deployment demo; not the user's existing Java business application. */
public class App {
    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        if (port < 1 || port > 65535) throw new IllegalArgumentException("Invalid PORT");
        String version = System.getenv().getOrDefault("APP_VERSION", "dev");
        if (!version.matches("[a-zA-Z0-9._-]{1,80}")) throw new IllegalArgumentException("Invalid APP_VERSION");
        AtomicLong count = new AtomicLong();
        var workers = Executors.newFixedThreadPool(4);
        var server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", exchange -> {
            count.incrementAndGet();
            String path = exchange.getRequestURI().getPath();
            String body; int status = 200;
            String type = "application/json; charset=utf-8";
            if (!exchange.getRequestMethod().equals("GET")) {
                status = 405; body = "{\"error\":\"method not allowed\"}";
                exchange.getResponseHeaders().set("Allow", "GET");
            } else if (path.equals("/health")) {
                if (Boolean.parseBoolean(System.getenv().getOrDefault("FAIL_HEALTH", "false"))) {
                    status = 503; body = "{\"status\":\"DOWN\"}";
                } else body = "{\"status\":\"UP\"}";
            } else if (path.equals("/")) {
                body = "{\"service\":\"java-devops-demo\",\"version\":\"" + version + "\"}";
            } else if (path.equals("/metrics")) {
                type = "text/plain; version=0.0.4; charset=utf-8";
                body = "# TYPE app_requests_total counter\napp_requests_total " + count.get() + "\n";
            } else { status = 404; body = "{\"error\":\"not found\"}"; }
            byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", type);
            exchange.getResponseHeaders().set("Cache-Control", "no-store");
            exchange.sendResponseHeaders(status, bytes.length);
            try (var out = exchange.getResponseBody()) { out.write(bytes); }
            System.out.printf("method=%s path=%s status=%d%n", exchange.getRequestMethod(),
                path.replaceAll("[\\r\\n\\t]", "_"), status);
        });
        server.setExecutor(workers);
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            server.stop(1); workers.shutdown();
        }));
        server.start();
        System.out.println("Listening on port " + port);
    }
}
