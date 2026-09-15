defmodule BlogWeb.TelemetryTest do
  use Blog.DataCase

  import Blog.AccountsFixtures

  describe "dispatch_app_stats/0" do
    test "emits a [:blog, :stats] event with user and visitor counts" do
      user_fixture()
      Blog.Analytics.track_visit("/", "some-visitor")

      test_pid = self()

      :telemetry.attach(
        "test-handler-#{inspect(test_pid)}",
        [:blog, :stats],
        fn _event, measurements, _metadata, _config ->
          send(test_pid, {:telemetry_event, measurements})
        end,
        nil
      )

      BlogWeb.Telemetry.dispatch_app_stats()

      assert_receive {:telemetry_event, measurements}
      assert measurements.users == 1
      assert measurements.visitors_today == 1
      assert measurements.visitors_week == 1

      :telemetry.detach("test-handler-#{inspect(test_pid)}")
    end
  end

  describe "metrics/0" do
    test "includes the custom app stats metrics" do
      app_stats_metrics =
        BlogWeb.Telemetry.metrics()
        |> Enum.filter(&(&1.event_name == [:blog, :stats]))
        |> Enum.map(& &1.measurement)

      assert :users in app_stats_metrics
      assert :visitors_today in app_stats_metrics
      assert :visitors_week in app_stats_metrics
    end
  end
end
