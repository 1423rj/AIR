//
//  AIRApp.swift
//  AIR
//
//  Created by Riley Pederson on 20/9/2023.
//

import SwiftUI

@main
struct AIRApp: App {
    @StateObject private var settings = UserSettings()
    
    init() {
        UserDefaults.standard.register(defaults: ["oneRM": 100.0])
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
func ceilToNearest(value: Double, nearest: Double) -> Double {
    return round(value / nearest) * nearest
}
struct Workout: Identifiable, Codable {
    var id: String
    var oneRM: Double
    var currentWeek: Int
    var currentDay: Int
    var setsCompleted: Int
}

class UserSettings: ObservableObject {
    @Published var oneRM: Double = 100.0
}



struct HomePageView: View {
    @State private var selectedTab = 0
    let exerciseImage = Image("b")
    let programImage = Image("Jackedguy")
    let WorkoutsImage = Image("BrowseWorkout")
    var body: some View {
        TabView(selection: $selectedTab) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                NavigationLink(
                    destination: ExerciseView(exercise: running),
                    label: {
                        ZStack {
                            exerciseImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text("Do a Specific Exercise")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                        }
                    })
                .frame(width: 170, height: 170)
                .clipped()
                .cornerRadius(10)

                NavigationLink(
                    destination: ProgramView(),
                    label: {
                        ZStack {
                            programImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text("Start a Program")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                        }
                    })
                .frame(width: 170, height: 170)
                .clipped()
                .cornerRadius(10)
                NavigationLink(
                    destination: SavedWorkoutsView(),
                    label: {
                        ZStack {
                            WorkoutsImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text("Browse Workouts")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                        }
                    })
                .frame(width: 170, height: 170)
                .clipped()
                .cornerRadius(10)
            }
            .padding()
            .navigationBarTitle("AIR", displayMode: .large)
        }
        .accentColor(.black)
    }
}



struct ProgressView: View {
    @EnvironmentObject var settings: UserSettings
    @AppStorage("savedWorkouts") var savedWorkouts: Data = Data()
    @State private var workout: Workout?
    
    
    // Initialize state variables based on the workout object
    @State private var workoutName: String = ""
  
    @State private var currentWeek: Int = 1
    @State private var currentDay: Int = 1
    @State private var setsCompleted: Int = 0
    
    @State private var currentOneRM: Double
    init(oneRM: Double, workout: Workout? = nil) {
        _currentOneRM = State(initialValue: oneRM)
        
        // If workout is not nil, update the State variables
        if let workout = workout {
            _currentOneRM = State(initialValue: workout.oneRM)
            _workout = State(initialValue: workout)
            _workoutName = State(initialValue: workout.id)
            _currentWeek = State(initialValue: workout.currentWeek)
            _currentDay = State(initialValue: workout.currentDay)
            _setsCompleted = State(initialValue: workout.setsCompleted)
        } else {
            _workoutName = State(initialValue: "") // Initialize with a unique ID
        }
    }
    var totalSets: [Int] = [6, 7, 8, 10]
    var totalReps: [Int] = [6, 5, 4, 3]
    var percentages: [Double] = [0.70, 0.75, 0.80, 0.85]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Week \(currentWeek), Day \(currentDay)")
                .font(.headline)
            
            if currentDay >= 1 && currentDay <= totalSets.count {
               
                Text("Sets Completed: \(setsCompleted) / \(totalSets[currentDay - 1])")

                            let baseWeight = ceilToNearest(value: currentOneRM * percentages[currentDay - 1], nearest: 2.5)
                            let adjustedWeight = baseWeight + Double(currentWeek - 1) * 5.0
                            Text("Weight: \(String(format: "%.1f", adjustedWeight)) kg")
                                .font(.headline)

                            Button(action: {
                                if setsCompleted + 1 < totalSets[currentDay - 1] {
                                    setsCompleted += 1
                                } else {
                                    setsCompleted = 0
                                    if currentDay < 4 {
                                        currentDay += 1
                                    } else {
                                        currentDay = 1
                                        if currentWeek < 4 {
                                            currentWeek += 1
                                        } else {
                                            currentWeek = 1
                                        }
                                    }
                        }
                        
                        // Update workout after change
                        self.workout = Workout(id: self.workoutName, oneRM: currentOneRM, currentWeek: self.currentWeek, currentDay: self.currentDay, setsCompleted: self.setsCompleted)
                        
                    }) {
                    Text("Complete Set")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("Invalid day")
            }
            
            Spacer()  // Push the button to the bottom
            
            
            TextField("Enter Workout Name", text: $workoutName)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)

            HStack(spacing: 10) {  // Add spacing between the buttons
                Button(action: {
                    self.currentDay = 1
                    self.currentWeek = 1
                    self.setsCompleted = 0
                }) {
                    Text("Reset")
                        .frame(maxWidth: .infinity) // Make the button take as much space as possible
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    if !workoutName.isEmpty {
                        saveWorkout()
                    }
                }) {
                    Text("Save Workout")
                        .frame(maxWidth: .infinity) // Make the button take as much space as possible
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal) // Add horizontal padding to the HStack
            
            
            .padding()
            .navigationBarTitle("Progress", displayMode: .inline)
        }
        
        
        
        
        .onChange(of: setsCompleted) { newValue in
            if !workoutName.isEmpty {
                    saveWorkout()
                }
        }
            
        
    }
    
    func saveWorkout() {
        guard !workoutName.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Prompt user to enter a workout name
            return
        }
        if (setsCompleted == 0 && currentDay == 1){
            return
        }
        else{
            do {
                var existingWorkouts = [Workout]()
                if let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkouts) {
                    existingWorkouts = decodedWorkouts
                }
                
                let currentWorkoutId = workout?.id ?? UUID().uuidString
                let currentWorkout = Workout(id: currentWorkoutId, oneRM: currentOneRM, currentWeek: currentWeek, currentDay: currentDay, setsCompleted: setsCompleted)
                    //...
                
                if let index = existingWorkouts.firstIndex(where: { $0.id == currentWorkoutId }) {
                    existingWorkouts[index] = currentWorkout
                } else {
                    existingWorkouts.append(currentWorkout)
                }
                
                // Update workout state after saving
                self.workout = currentWorkout
                
                let encodedWorkouts = try JSONEncoder().encode(existingWorkouts)
                self.savedWorkouts = encodedWorkouts
            } catch {
                print("Error saving workout: \(error)")
            }
        }
        
    }

}
    
    
    
    
    
    
    struct ProgressView_Previews: PreviewProvider {
        @EnvironmentObject var settings: UserSettings
        @State static var previewOneRM: Double = 100.0
        
        static var previews: some View {
            ProgressView(oneRM: previewOneRM)
        }
    }
    
    struct ProgramView: View {
        @EnvironmentObject var settings: UserSettings
        @AppStorage("currentWeek") var currentWeek: Int = 1
        let percentages: [Double] = [0.7, 0.75, 0.8, 0.85]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Smolov Jr.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter your 1RM:")
                        .font(.headline)
                    
                    TextField("Weight", value: $settings.oneRM, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Divider()
                    ForEach(1...4, id: \.self) { week in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Week \(week)")
                                .font(.headline)

                            ForEach(percentages, id: \.self) { percentage in
                                HStack {
                                    Text("Set \(self.percentages.firstIndex(of: percentage)! + 1):")
                                        .fontWeight(.semibold)

                                    Spacer()

                                    let baseWeight = self.ceilToNearest(value: settings.oneRM * percentage, nearest: 2.5)
                                    let adjustedWeight = baseWeight + Double(week - 1) * 5.0
                                    Text("\(String(format: "%.1f", adjustedWeight)) kg")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    

                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ProgressView(oneRM: settings.oneRM)) {
                        Text("Start Workout")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
                .navigationBarTitle("Smolov Jr.", displayMode: .inline)
            }
        }
        
        func ceilToNearest(value: Double, nearest: Double) -> Double {
            return round(value / nearest) * nearest
        }
       
    }
    

    
    
    
    struct ProgramView_Previews: PreviewProvider {
        static var previews: some View {
            ProgramView()
        }
    }
    
    struct HomePageView_Previews: PreviewProvider {
        static var previews: some View {
            HomePageView()
        }
    }
    
    
    struct Exercise: Identifiable {
        var id = UUID()
        var name: String
        var type: ExerciseType
        var duration: Int
        var caloriesBurned: Int
        var equipmentNeeded: [String]
        var instructions: String
    }
    
    enum ExerciseType: String {
        case aerobic = "Aerobic"
        case anaerobic = "Anaerobic"
    }
    
    let running = Exercise(
        name: "Running",
        type: .aerobic,
        duration: 30,
        caloriesBurned: 300,
        equipmentNeeded: ["Running Shoes"],
        instructions: "Start with a 5-minute warm-up jog at a moderate pace. Then run at a steady pace for the desired duration. Finish with a 5-minute cool-down walk."
    )
    
    struct ExerciseView: View {
        var exercise: Exercise
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.name)
                    .font(.largeTitle)
                Text(exercise.type.rawValue.capitalized)
                    .font(.title)
                    .foregroundColor(.gray)
                HStack {
                    Text("Duration:")
                        .font(.headline)
                    Text("\(exercise.duration) minutes")
                }
                HStack {
                    Text("Calories Burned:")
                        .font(.headline)
                    Text("\(exercise.caloriesBurned)")
                }
                HStack {
                    Text("Equipment Needed:")
                        .font(.headline)
                    Text(exercise.equipmentNeeded.joined(separator: ", "))
                }
                Text("Instructions:")
                    .font(.headline)
                Text(exercise.instructions)
            }
            .padding()
        }
    }

    
    struct ExerciseView_Previews: PreviewProvider {
        static var previews: some View {
            ExerciseView(exercise: running)
        }
    }
    
    
struct SavedWorkoutsView: View {
    @EnvironmentObject var settings: UserSettings
    @AppStorage("savedWorkouts") var savedWorkoutsData: Data = Data()
    @State private var savedWorkouts: [Workout] = []
    @State private var selectedWorkout: Workout?
    @State private var isActive: Bool = false

    var body: some View {
        List {
            ForEach(savedWorkouts, id: \.id) { workout in
                Button(action: {
                    self.selectedWorkout = workout
                    self.isActive = true
                }) {
                    Text(workout.id)
                }
            }
            .onDelete(perform: deleteWorkout)
        }
        .navigationTitle("Saved Workouts")
        .navigationBarItems(trailing: EditButton()) // Adds an Edit button to enable deletion
        .background(
            NavigationLink("", destination: ProgressView(oneRM: settings.oneRM, workout: selectedWorkout)
                .onDisappear { self.isActive = false }, isActive: $isActive)
                .opacity(0) // Hide the NavigationLink
        )
        .onAppear {
            decodeSavedWorkouts()
        }
    }
    
    func decodeSavedWorkouts() {
        if let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkoutsData) {
            savedWorkouts = decodedWorkouts
        }
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { index in
            savedWorkouts.remove(at: index)
        }
        let updatedWorkoutsData = try? JSONEncoder().encode(savedWorkouts)
        savedWorkoutsData = updatedWorkoutsData ?? Data()
    }
}



