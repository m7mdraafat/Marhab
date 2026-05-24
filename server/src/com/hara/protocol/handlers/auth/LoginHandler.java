package com.hara.protocol.handlers.auth;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Properties;

/**
 * Login handler with simple persistent accounts.
 *
 * Storage: <SFS>/extensions/MyGameExtension/users.properties
 *   each line is "<username>=<sha256(password):isoTimestamp>"
 *
 * Behaviour:
 *   - first time a username is seen -> registered (password recorded)
 *   - subsequent logins -> password must match
 *   - empty/null password is allowed in dev (logged with WARN) for quick local testing
 *
 * This is intentionally NOT a real auth system. Good enough for "me and my
 * friends on a small server", swap for a DB-backed solution before going wider.
 */
public class LoginHandler extends BaseClientRequestHandler {

    private static final String USERS_FILE = "users.properties";
    private static final Object FILE_LOCK = new Object();

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        String submitted = params != null && params.containsKey("password")
                ? params.getUtfString("password") : "";
        String hash = sha256(submitted);

        Properties users = loadUsers();
        String stored = users.getProperty(user.getName());
        boolean firstTime = (stored == null);

        if (firstTime) {
            users.setProperty(user.getName(), hash + ":" + java.time.Instant.now());
            saveUsers(users);
            trace("LoginHandler: registered NEW user '" + user.getName() + "' id=" + user.getId());
        } else {
            String storedHash = stored.split(":", 2)[0];
            if (!storedHash.equals(hash)) {
                trace("LoginHandler: PASSWORD MISMATCH for '" + user.getName()
                        + "' -- returning ok=false (client may treat as login failure)");
                ISFSObject resp = new SFSObject();
                resp.putBool("ok", false);
                resp.putUtfString("error", "bad password");
                send("login", resp, user);
                return;
            }
            trace("LoginHandler: returning user '" + user.getName() + "' id=" + user.getId());
        }

        ISFSObject resp = new SFSObject();
        resp.putBool("ok", true);
        resp.putBool("newAccount", firstTime);
        resp.putUtfString("userName", user.getName());
        resp.putInt("playerId", user.getId());
        send("login", resp, user);
    }

    private File usersFile() {
        // BaseClientRequestHandler exposes getParentExtension() which gives us
        // a folder under SFS's extensions/ dir we can use for our own files.
        File extDir = new File("extensions/MyGameExtension");
        if (!extDir.exists()) {
            extDir.mkdirs();
        }
        return new File(extDir, USERS_FILE);
    }

    private Properties loadUsers() {
        Properties p = new Properties();
        File f = usersFile();
        if (!f.exists()) return p;
        synchronized (FILE_LOCK) {
            try (FileInputStream in = new FileInputStream(f)) {
                p.load(in);
            } catch (IOException e) {
                trace("LoginHandler: failed to load users.properties -- " + e.getMessage());
            }
        }
        return p;
    }

    private void saveUsers(Properties p) {
        synchronized (FILE_LOCK) {
            try (FileOutputStream out = new FileOutputStream(usersFile())) {
                p.store(out, "MyGame users (managed by LoginHandler)");
            } catch (IOException e) {
                trace("LoginHandler: failed to save users.properties -- " + e.getMessage());
            }
        }
    }

    private static String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(s == null ? new byte[0] : s.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(hash.length * 2);
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }
}
