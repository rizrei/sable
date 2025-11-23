defmodule Sable.ExerciseTest do
  use Sable.DataCase, async: true

  test "test" do
    exercise = insert(:barbell_bench_press_exercise)
    metric = insert(:reps_metric)
    exercise_metric = insert(:exercise_metric)
  end
end
