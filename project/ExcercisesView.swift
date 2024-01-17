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
        let defaultTime: Int = 60
        if let savedData = UserDefaults.standard.data(forKey: "excercises") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode([Excercise].self, from: savedData) {
                list = loadedData
                return
            }
        }
        
        list = [
            Excercise(name: "Книжка", duration: defaultTime),
            Excercise(name: "Скручивания (велосипед)", duration: defaultTime),
            Excercise(name: "Мостик", duration: defaultTime),
            Excercise(name: "Планка", duration: defaultTime),
            Excercise(name: "Боковая планка: левая сторона", duration: defaultTime),
            Excercise(name: "Боковая планка: правая сторона", duration: defaultTime)
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
                        customText(item.name)
                    }
                    .onDelete(perform: deleteItem)
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .listStyle(PlainListStyle())

             .padding()
                NavigationLink(destination: ExercisesStartView()) { customText("Перейти к выполнению")
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentExerciseIndex = 0
    @State private var timerSeconds = 0
    @State private var isTimerRunning = false
    @State private var isExercise = true
    @State private var isBreak = false
    @State private var timer: Timer?
    @State private var timerProgress: CGFloat = 1.0

    var body: some View {
        VStack {
            customText("Текущее упражнение:")
            Text("\(exercises.list[currentExerciseIndex].name)")
                .font(Font.custom("Comfortaa", size: 20))
                .bold()
                .foregroundColor(.orange)
                .padding(.bottom)

            ZStack {
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0))

                Text("\(timerSeconds)")
                    .font(Font.custom("Comfortaa", size: 40))
            }
            .padding()

            Button(action: {
                startTimer()
            }) {
                customText(isTimerRunning ? "Пауза" : "Начать")
                    .padding()
                    .bold()
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .padding()

            if currentExerciseIndex < exercises.list.count - 1 {
                customText("Следующее упражнение:")
                Text("\(exercises.list[currentExerciseIndex + 1].name)")
                    .font(Font.custom("Comfortaa", size: 20))
                    .bold()
                    .foregroundColor(.orange)
            } else {
                customText("Это последнее упражнение!")
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
            resetTimer()
            currentExerciseIndex = 0
            presentationMode.wrappedValue.dismiss()
        }
        resetTimer()
    }

    func resetTimer() {
        timer?.invalidate()
        timerSeconds = exercises.list[currentExerciseIndex].duration
        timerProgress = 1.0
        isTimerRunning = false
    }
}

#Preview {
    ExercisesView()
}
