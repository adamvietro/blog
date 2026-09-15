defmodule BlogWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.start.system_time",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.start.system_time",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.exception.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      summary("phoenix.socket_connected.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.channel_joined.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.channel_handled_in.duration",
        tags: [:event],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("blog.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("blog.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("blog.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("blog.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("blog.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # App Metrics
      last_value("blog.stats.users", description: "Total registered users"),
      last_value("blog.stats.visitors_today", description: "Unique visitors in the last 24h"),
      last_value("blog.stats.visitors_week", description: "Unique visitors in the last 7 days")
    ]
  end

  defp periodic_measurements do
    if Application.get_env(:blog, :analytics_enabled, true) do
      [{__MODULE__, :dispatch_app_stats, []}]
    else
      []
    end
  end

  # BlogWeb.Telemetry (and its telemetry_poller child, which fires an
  # eager first measurement immediately on start) is started before
  # Blog.Repo in the application's supervision tree, so this can run
  # before the Repo is registered — skip that first tick rather than crash.
  @doc false
  def dispatch_app_stats do
    if Process.whereis(Blog.Repo) do
      do_dispatch_app_stats()
    end
  end

  defp do_dispatch_app_stats do
    now = DateTime.utc_now()

    :telemetry.execute([:blog, :stats], %{
      users: Blog.Analytics.count_users(),
      visitors_today: Blog.Analytics.count_unique_visitors_since(DateTime.add(now, -1, :day)),
      visitors_week: Blog.Analytics.count_unique_visitors_since(DateTime.add(now, -7, :day))
    })
  end
end
