defmodule BlogWeb.Router do
  use BlogWeb, :router

  import BlogWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug BlogWeb.Plugs.TrackVisit
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through [:browser, :require_authenticated_user]

    post "/posts/:id/comments/new", CommentController, :create
    get "/posts/:id/comments/new", CommentController, :new
    delete "/posts/:id/comments/:comment_id", CommentController, :delete
    get "/posts/:id/comments/:comment_id/edit", CommentController, :edit
    put "/posts/:id/comments/:comment_id/edit", CommentController, :update
    get "/notifications", NotificationController, :index
    post "/notifications/:id/mark_read", NotificationController, :mark_read
    post "/notifications/mark_all_read", NotificationController, :mark_all_read
  end

  scope "/", BlogWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    get "/tags", TagController, :index
    get "/tags/new", TagController, :new
    post "/tags", TagController, :create
    put "/tags/:id", TagController, :update
    delete "/tags/:id", TagController, :delete
    post "/posts", PostController, :create
    get "/posts/new", PostController, :new
    post "/posts/preview", PostController, :preview
    put "/posts/:id", PostController, :put
    get "/posts/:id/edit", PostController, :edit
    post "/posts/:id", PostController, :edit
    delete "/posts/:id", PostController, :delete
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/feed.xml", FeedController, :index
    get "/sitemap.xml", SitemapController, :index
    get "/posts", PostController, :index
    get "/posts/:id", PostController, :show
    get "/search", PostController, :search
    get "/tags/search", TagController, :search
    get "/posts/:id/comments", CommentController, :show
  end

  # These must come after the "/tags/search" route above, since ":id" would
  # otherwise greedily match the literal path segment "search" first.
  scope "/", BlogWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    get "/tags/:id", TagController, :show
    get "/tags/:id/edit", TagController, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end

  # LiveDashboard is available in every environment (dev and prod), but
  # gated behind the same admin-only pipeline as the rest of the admin
  # section — it's never reachable by anyone but a logged-in admin.
  import Phoenix.LiveDashboard.Router

  scope "/dev" do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
  end

  # The mailbox preview shows the actual content of outgoing emails
  # (password resets, confirmations, etc.), so it stays dev-only regardless
  # of login state — not something to expose even to an authenticated admin
  # in production.
  if Application.compile_env(:blog, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BlogWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BlogWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", BlogWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
