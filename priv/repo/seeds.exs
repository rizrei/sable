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
gym_tag = %Tag{title: "Gym"}
cardio_tag = %Tag{title: "Cardio"}
legs_tag = %Tag{title: "Legs"}
back_tag = %Tag{title: "Back"}
chest_tag = %Tag{title: "Сhest"}
monday_tag = %Tag{title: "Monday"}

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
      %WorkoutExercise{exercise: barbell_bench_press_exercise},
      %WorkoutExercise{exercise: push_up_exercise}
    ]
  }
  |> Repo.insert!()
