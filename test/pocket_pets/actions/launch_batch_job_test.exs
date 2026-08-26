defmodule PocketPets.Actions.LaunchBatchJobTest do
  use ExUnit.Case, async: true

  alias PocketPets.Actions.LaunchBatchJob

  test "dry run returns a BATCH job with a real timeout" do
    assert {:ok, %{status: :dry_run, job: job}} =
             Jido.Exec.run(LaunchBatchJob, %{
               image: "ghcr.io/chops/gpu-worker",
               max_timeout_run_ms: 600_000
             })

    assert job.task == "BATCH"
    assert job.max_timeout_run_ms == 600_000
    assert job.parameters.parameters.image == "ghcr.io/chops/gpu-worker"
  end
end
