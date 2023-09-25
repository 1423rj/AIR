//
//  AIRApp.swift
//  AIR
//
//  Created by Riley Pederson on 20/9/2023.
//

import SwiftUI



@main
struct AIRApp: App {
    init() {
            // Register the initial value for the "oneRM" key
            UserDefaults.standard.register(defaults: ["oneRM": 100.0])
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

import SwiftUI

struct HomePageView: View {
    @State private var selectedTab = 0
    
    // Sample images for the panels (replace with your own images)
    let exerciseImage = Image("b")
    let programImage = Image("Jackedguy")
    
    var body: some View {
            TabView(selection: $selectedTab) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    
                    // First Panel: Do a Specific Exercise
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
                    
                    // Second Panel: Start a Program
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
                    
                    // Placeholder for the third panel
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .overlay(Text("Coming Soon")
                                    .font(.title2)
                                    .foregroundColor(.black)
                        )
                        .frame(width: 170, height: 170)
                        .cornerRadius(10)
                    
                    // Placeholder for the fourth panel
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .overlay(Text("Coming Soon")
                                    .font(.title2)
                                    .foregroundColor(.black)
                        )
                        .frame(width: 170, height: 170)
                        .cornerRadius(10)
                }
                .padding()
                                .navigationBarTitle("AIR", displayMode: .large)
            }
            
        
        .accentColor(.black)
    }
}


struct ProgressView: View {
    @AppStorage("oneRM") var oneRM: Double = 100.0
    @AppStorage("currentWeek") var currentWeek: Int = 1
    @AppStorage("currentDay") private var currentDay: Int = 1
    
    var totalSets: [Int] = [6, 7, 8, 10]
    var totalReps: [Int] = [6, 5, 4, 3]
    var percentages: [Double] = [0.70, 0.75, 0.80, 0.85]
    
    @State private var setsCompleted = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Progress")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Week \(currentWeek), Day \(currentDay)")
                .font(.headline)
            
            if currentDay >= 1 && currentDay <= totalSets.count {
                Text("Sets Completed: \(setsCompleted) / \(totalSets[currentDay - 1])")
                
                Text("Weight: \(String(format: "%.1f", ceilToNearest(value: oneRM * (percentages[currentDay - 1] + Double(5 * (currentWeek - 1))/100), nearest: 2.5))) kg")
                    .font(.headline)
                
                Button(action: {
                    if setsCompleted < totalSets[currentDay - 1] {
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

            Button(action: {
                self.currentDay = 1
                self.currentWeek = 1
                self.setsCompleted = 0
            }) {
                Text("Reset")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationBarTitle("Progress", displayMode: .inline)
    }

    func ceilToNearest(value: Double, nearest: Double) -> Double {
        return round(value / nearest) * nearest
    }
}






struct ProgressView_Previews: PreviewProvider {
    @State static var previewOneRM: Double = 100.0

    static var previews: some View {
        ProgressView()
    }
}

struct ProgramView: View {
    @AppStorage("oneRM") var oneRM: Double = 100.0
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
                
                TextField("Weight", value: $oneRM, format: .number)
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
                                
                                Text("\(String(format: "%.1f", self.ceilToNearest(value: oneRM * (percentage + Double(5 * (week - 1))/100), nearest: 2.5))) kg")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                NavigationLink(destination: ProgressView()) {
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
