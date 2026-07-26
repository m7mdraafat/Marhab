package com.mygame.server.auth;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping(value = "/register", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String registerPage() {
        return page("Register", """
            <form method="post" action="/auth/register">
              <label>Character Name <input name="characterName" required maxlength="32"></label>
              <label>Email <input name="email" type="email" required></label>
              <label>Password <input name="password" type="password" required minlength="6"></label>
              <label>Gender Type
                <select name="gender" required>
                  <option value="m">Male</option>
                  <option value="f">Female</option>
                </select>
              </label>
              <button type="submit">Register</button>
            </form>
            """);
    }

    @PostMapping(value = "/register", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String register(
        @RequestParam String characterName,
        @RequestParam String email,
        @RequestParam String password,
        @RequestParam String gender
    ) {
        try {
            AuthBridgeResult result = authService.register(characterName, email, password, gender);
            return successPage("Account created", result.avatarId());
        } catch (IllegalArgumentException error) {
            return errorPage("Registration failed", error.getMessage(), "/auth/register");
        }
    }

    @GetMapping(value = "/login", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String loginPage() {
        return page("Login", """
            <form method="post" action="/auth/login">
              <label>Email <input name="email" type="email" required></label>
              <label>Password <input name="password" type="password" required></label>
              <button type="submit">Login</button>
            </form>
            """);
    }

    @PostMapping(value = "/login", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String login(@RequestParam String email, @RequestParam String password) {
        try {
            AuthBridgeResult result = authService.login(email, password);
            return successPage("Login complete", result.avatarId());
        } catch (IllegalArgumentException error) {
            return errorPage("Login failed", error.getMessage(), "/auth/login");
        }
    }

    private String successPage(String title, String avatarId) {
        return page(title, """
            <p>Avatar %s is ready.</p>
            <p>You can return to the game window now.</p>
            """.formatted(escape(avatarId)));
    }

    private String errorPage(String title, String message, String href) {
        return page(title, """
            <p class="error">%s</p>
            <p><a href="%s">Try again</a></p>
            """.formatted(escape(message), href));
    }

    private String page(String title, String body) {
        return """
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width,initial-scale=1">
              <title>%s</title>
              <style>
                body { font-family: Segoe UI, sans-serif; margin: 2rem; max-width: 32rem; }
                form { display: grid; gap: 1rem; }
                label { display: grid; gap: .35rem; }
                input, select, button { font: inherit; padding: .6rem; }
                button { cursor: pointer; }
                .error { color: #b00020; }
              </style>
            </head>
            <body>
              <h1>%s</h1>
              %s
            </body>
            </html>
            """.formatted(escape(title), escape(title), body);
    }

    private String escape(String value) {
        return value == null ? "" : value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}