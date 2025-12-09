alias Sable.Repo

alias Sable.{
  Exercises.Exercise,
  Accounts.User,
  Tags.Tag,
  Workouts.Workout,
  Workouts.WorkoutTag,
  Workouts.WorkoutExercise,
  Workouts.UserWorkout,
  Sets.Set
}

defmodule Helpers do
  def random_datetime() do
    start_ts = DateTime.utc_now() |> DateTime.to_unix()
    end_ts = DateTime.utc_now() |> DateTime.shift(year: -1) |> DateTime.to_unix()
    random_ts = :rand.uniform(start_ts - end_ts) + end_ts
    DateTime.from_unix!(random_ts)
  end
end

user =
  %User{email: "test@example.com", hashed_password: Bcrypt.hash_pwd_salt("Passw0rd")}
  |> Repo.insert!()

# rep_metric = %Metric{title: "rep", unit: "quantity"} |> Repo.insert!()
# weight_metric = %Metric{title: "Weight", unit: "kg"} |> Repo.insert!()
# distance_metric = %Metric{title: "Distance", unit: "meter"} |> Repo.insert!()
gym_tag = %Tag{title: "Gym", color: "#b93559"}
cardio_tag = %Tag{title: "Cardio", color: "#7892cd"}
legs_tag = %Tag{title: "Legs", color: "#a80b70"}
back_tag = %Tag{title: "Back", color: "#e79807"}
chest_tag = %Tag{title: "Сhest", color: "#f52d7d"}
monday_tag = %Tag{title: "Monday", color: "#ff6f6f"}

barbell_bench_press_exercise =
  %Exercise{
    title: "Barbell bench press",
    metrics: [:rep, :weight]
  }
  |> Repo.insert!()

push_up_exercise =
  %Exercise{
    title: "Push-up",
    metrics: [:rep],
    author: user
  }
  |> Repo.insert!()

deadlift_exercise =
  %Exercise{
    title: "Deadlift",
    metrics: [:rep, :weight],
    author: user
  }
  |> Repo.insert!()

workout =
  %Workout{
    title: "WorkoutTitle",
    description: "WorkoutDescription",
    author: user,
    tags: [gym_tag, monday_tag, chest_tag],
    user_workouts: [%UserWorkout{user: user}],
    workout_exercises: [
      %WorkoutExercise{position: 1, exercise: barbell_bench_press_exercise},
      %WorkoutExercise{position: 2, exercise: push_up_exercise}
    ]
  }
  |> Repo.insert!()

1..100
|> Enum.each(fn n ->
  %Set{
    user: user,
    exercise: push_up_exercise,
    metrics: %Sable.SetMetrics{rep: Enum.random(5..20)},
    inserted_at: Helpers.random_datetime()
  }
  |> Repo.insert!()
end)

1..100
|> Enum.each(fn n ->
  %Set{
    user: user,
    exercise: barbell_bench_press_exercise,
    metrics: %Sable.SetMetrics{rep: Enum.random(5..10), weight: Enum.random(70..100)},
    inserted_at: Helpers.random_datetime()
  }
  |> Repo.insert!()
end)

# %Set{
#   user: user,
#   exercise: barbell_bench_press_exercise,
#   metrics: %Sable.SetMetrics{rep: 10, weight: 100}
# }
# |> Repo.insert!()

# %Set{
#   user: user,
#   exercise: barbell_bench_press_exercise,
#   metrics: %Sable.SetMetrics{rep: 8, weight: 120}
# }
# |> Repo.insert!()
