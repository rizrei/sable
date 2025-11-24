alias Sable.Repo

alias Sable.{
  Exercises.Exercise,
  Exercises.ExerciseMetric,
  Exercises.Metric,
  User,
  Tag,
  Workouts.Workout,
  Workouts.WorkoutTag,
  Workouts.WorkoutExercise
}

user = %User{first_name: "Dima", last_name: "F", phone: "+79999999999"} |> Repo.insert!()
reps_metric = %Metric{title: "Reps", unit: "quantity"} |> Repo.insert!()
weight_metric = %Metric{title: "Weight", unit: "kg"} |> Repo.insert!()
distance_metric = %Metric{title: "Distance", unit: "meter"} |> Repo.insert!()
gym_tag = %Tag{title: "Gym", color: "#b93559"}
cardio_tag = %Tag{title: "Cardio", color: "#7892cd"}
legs_tag = %Tag{title: "Legs", color: "#a80b70"}
back_tag = %Tag{title: "Back", color: "#e79807"}
chest_tag = %Tag{title: "Сhest", color: "#f52d7d"}
monday_tag = %Tag{title: "Monday", color: "#ff6f6f"}

barbell_bench_press_exercise =
  %Exercise{
    title: "Barbell bench press",
    exercise_metrics: [
      %ExerciseMetric{metric: reps_metric},
      %ExerciseMetric{metric: weight_metric}
    ]
  }
  |> Repo.insert!()

push_up_exercise =
  %Exercise{
    title: "Push-up",
    exercise_metrics: [
      %ExerciseMetric{metric: reps_metric}
    ]
  }
  |> Repo.insert!()

deadlift_exercise =
  %Exercise{
    title: "Deadlift",
    exercise_metrics: [
      %ExerciseMetric{metric: reps_metric},
      %ExerciseMetric{metric: weight_metric}
    ]
  }
  |> Repo.insert!()

workout =
  %Workout{
    title: "WorkoutTitle",
    description: "WorkoutDescription",
    author: user,
    workout_tags: [
      %WorkoutTag{tag: gym_tag},
      %WorkoutTag{tag: monday_tag},
      %WorkoutTag{tag: chest_tag}
    ],
    workout_exercises: [
      %WorkoutExercise{position: 1, exercise: barbell_bench_press_exercise},
      %WorkoutExercise{position: 2, exercise: push_up_exercise}
    ]
  }
  |> Repo.insert!()
