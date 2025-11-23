alias Sable.Repo
alias Sable.{Exercise, ExerciseMetric, Metric}

reps_metric = %Metric{title: "Reps", unit: "quantity"} |> Repo.insert!()
weight_metric = %Metric{title: "Weight", unit: "kg"} |> Repo.insert!()
distance_metric = %Metric{title: "Distance", unit: "meter"} |> Repo.insert!()

%Exercise{
  title: "Barbell bench press",
  exercise_metrics: [
    %ExerciseMetric{metric: reps_metric},
    %ExerciseMetric{metric: weight_metric}
  ]
}
|> Repo.insert!()

%Exercise{
  title: "Push-up",
  exercise_metrics: [
    %ExerciseMetric{metric: reps_metric}
  ]
}
|> Repo.insert!()

%Exercise{
  title: "Deadlift",
  exercise_metrics: [
    %ExerciseMetric{metric: reps_metric},
    %ExerciseMetric{metric: weight_metric}
  ]
}
|> Repo.insert!()
