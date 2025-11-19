package main

import (
	"log/slog"
	"net/http"
	"os"

	"mock-oidc/config"
	"github.com/zitadel/oidc/v3/example/server/exampleop"
	"github.com/zitadel/oidc/v3/example/server/storage"
)

func getUserStore(cfg *config.Config) (storage.UserStore, error) {
	if cfg.UsersFile == "" {
		return storage.NewUserStore(cfg.Issuer), nil
	}
	return storage.StoreFromFile(cfg.UsersFile)
}

func main() {
	cfg := config.FromEnvVars(&config.Config{
		Issuer: "http://localhost:9998",
		Port: "9998",
	})
	logger := slog.New(
		slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{
			AddSource: true,
			Level:     slog.LevelDebug,
		}),
	)

	issuer := cfg.Issuer

	storage.RegisterClients(
		storage.NativeClient("native", cfg.RedirectURI...),
		storage.WebClient("web", "secret", cfg.RedirectURI...),
		storage.WebClient("api", "secret", cfg.RedirectURI...),
	)

	// the OpenIDProvider interface needs a Storage interface handling various checks and state manipulations
	// this might be the layer for accessing your database
	// in this example it will be handled in-memory
	store, err := getUserStore(cfg)
	if err != nil {
		logger.Error("cannot create UserStore", "error", err)
		os.Exit(1)
	}

	stor := storage.NewStorage(store)
	router := exampleop.SetupServer(
		issuer,
		stor,
		logger,
		false,
		//op.WithCrypto(newMyCrypto(sha256.Sum256([]byte("test")), logger)),
	)

	server := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
	}
	logger.Info("server listening, press ctrl+c to stop", "port", cfg.Port)
	if server.ListenAndServe() != http.ErrServerClosed {
		logger.Error("server terminated", "error", err)
		os.Exit(1)
	}
}
