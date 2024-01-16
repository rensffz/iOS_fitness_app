//
//  exercisesView.swift
//  project
//
//  Created by Анастасия Сергеева on 05.01.2024.
//

import SwiftUI

struct Excercise: Codable, Hashable {    
    var name: String
    var duration: Int
}

class Excercises: ObservableObject {
    @Published var list: [Excercise] {
        didSet {
            saveData()
        }
    }

    init() {
        if let savedData = UserDefaults.standard.data(forKey: "excercises") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([Excercise].self, from: savedData) {
                list = loadedData
                return
            }
        }
        
        list = [
            Excercise(name: "Махи на боку", duration: 60),
            Excercise(name: "Книжка", duration: 60),
            Excercise(name: "Скручивания велосипед", duration: 60),
            Excercise(name: "Мостик", duration: 60),
            Excercise(name: "Планка", duration: 60),
            Excercise(name: "Боковая планка", duration: 60)
            ]
    }

    func saveData() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(list) {
            UserDefaults.standard.set(encodedData, forKey: "excercises")
        }
    }
    
    func addExercise(_ name: String, _ duration: Int) {
        list.append(Excercise(name: name, duration: duration))
    }
}

struct ExercisesView: View {
    @ObservedObject var exercises = Excercises()
    //@State private var exercises: [String] = []
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: AddExerciseView(exercises: exercises)) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "#0CA2AF"))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .padding()
                    }
                }

                List {
                    ForEach(exercises.list, id: \.self) { item in
                        Text(item.name)
                    }
                    .onDelete(perform: deleteItem)
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .listStyle(PlainListStyle())

             .padding()
                NavigationLink(destination: ExercisesStartView()) { Text("Начать")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
            }
        }
    }
    func deleteItem(at offsets: IndexSet) {
        exercises.list.remove(atOffsets: offsets)
    }
}

struct AddExerciseView: View {
    @ObservedObject var exercises = Excercises()
    @State private var name: String = ""
    @State private var duration: Int = 0
    @State private var selectedMinutes = 1
    @State private var selectedSeconds = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            NavigationView {
                Form {
                    Section(header: Text("Добавить упражнение")) {
                        TextField("Введите название", text: $name)
                            //.padding()
                    }
                    Section(header: Text("Добавить продолжительность")) {

                            Picker(selection: $duration, label: Text("Секунды")) {
                                ForEach(0..<61) {
                                    Text("\($0) сек")
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            
                    }
                }
            }
            .navigationBarItems(
                trailing: Button("Добавить") {
                    if name != "" {
                        exercises.addExercise(name, duration)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ExercisesStartView: View {
    @ObservedObject var exercises = Excercises()
    
    //let exercises = [("Упражнение 1", 30), ("Упражнение 2", 45), ("Упражнение 3", 60)]
    
    @State private var currentExerciseIndex = 0
    @State private var timerSeconds = 0
    @State private var isTimerRunning = true
    @State private var isExercise = true
    @State private var isBreak = false
    @State private var timer: Timer?
    @State private var timerProgress: CGFloat = 1.0

    var body: some View {
        VStack {
            Text("Текущее упражнение: \(exercises.list[currentExerciseIndex].name)")
                .padding()

            ZStack {
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0))
                    //.frame(width: 200, height: 200)

                Text("\(timerSeconds)")
                    .font(.title)
            }
            //.background(.black)
            .padding()
            //.clipShape(Circle())
            //.position(x: 200, y: 200)

            Button(action: {
                startTimer()
            }) {
                Text(isTimerRunning ? "Пауза" : "Начать")
            }
            .padding()

            if currentExerciseIndex < exercises.list.count - 1 {
                Text("Следующее упражнение: \(exercises.list[currentExerciseIndex + 1].name)")
                    .padding()
            } else {
                Text("Это последнее упражнение!")
                    .padding()
            }
        }
        .onAppear {
            resetTimer()
        }
    }

    func startTimer() {
        if isTimerRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if timerSeconds > 0 {
                    timerSeconds -= 1
                    withAnimation {
                        timerProgress = CGFloat(timerSeconds) / CGFloat(exercises.list[currentExerciseIndex].duration)
                    }
                } else {
                    nextExercise()
                }
            }
        }

        isTimerRunning.toggle()
    }

    func nextExercise() {
        if currentExerciseIndex < exercises.list.count - 1 {
            currentExerciseIndex += 1
        } else {
            // Все упражнения завершены
            resetTimer()
            currentExerciseIndex = 0
        }

        resetTimer()
    }

    func resetTimer() {
        timer?.invalidate()
        timerSeconds = exercises.list[currentExerciseIndex].duration
        timerProgress = 1.0
        //isTimerRunning = false
    }
}

#Preview {
    ExercisesView()
}

/**
 struct ExercisesStartView: View {
     @ObservedObject var exercises = Excercises()
     
     @State private var timeRemaining = 60
     @State private var isTimerRunning = false
     let timerInterval = 1.0
     
     var body: some View {
         VStack {
             ZStack {
                 Circle()
                     .stroke(lineWidth: 10)
                     .opacity(0.3)
                     .foregroundColor(.blue)
                 Circle()
                     .trim(from: 0.0, to: CGFloat(timeRemaining) / 60.0)
                     .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                     .foregroundColor(.blue)
                     .rotationEffect(.degrees(-90))
                 
                 Button(action: {
                     if self.isTimerRunning {
                         print("going")
                         self.stopTimer()
                     } else {
                         print("no")
                         self.startTimer()
                     }
                 }) {
                     Text("\(timeRemaining)")
                         .font(.title)
                         .foregroundColor(.black)
                 }
             }
             .frame(width: 200, height: 200)
             Spacer()
             Text("HW")
             Spacer()
         }
     }
     
     private func startTimer() {
         isTimerRunning = true
         Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
             withAnimation {
                 if self.timeRemaining > 0 {
                     self.timeRemaining -= 1
                 } else {
                     self.stopTimer()
                 }
             }
         }
     }
     
     private func stopTimer() {
         isTimerRunning = false
     }
 }
 */
