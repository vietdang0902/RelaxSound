//import SwiftUI
//
//struct SetTimerView: View {
//    @Binding var isPresented: Bool
//    @Binding var selectedTimer: String
//    @State private var showCustomPicker = false
//    @EnvironmentObject var timerManager: TimerManager
//
//    let timerOptions = [
//        "No timer", "Custom", "5 min" , "10 min", "15 min", "20 min", "25 min", "30 min", "45 min", "1 hour", "1.5 hour", "2 hour",
//    ]
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Set timer")
//                .font(.headline)
//                .padding(.top, 24)
//            List {
//                ForEach(timerOptions, id: \.self) { option in
//                    Button(action: {
//                        if option == "Custom" {
//                            showCustomPicker = true
//                        } else {
//                            selectedTimer = option
//                            timerManager.startTimer(seconds: secondsForOption(option))
//                            isPresented = false
//                        }
//                    }) {
//                        HStack {
//                            Text(option)
//                            Spacer()
//                            if selectedTimer == option {
//                                Image(systemName: "checkmark")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                    .foregroundColor(.primary)
//                }
//            }
//            .listStyle(PlainListStyle())
//            Button(action: { isPresented = false }) {
//                Image(systemName: "xmark")
//                    .font(.title2)
//                    .foregroundColor(.red)
//                    .padding(15)
//                    .background(Color.gray.opacity(0.15))
//                    .clipShape(Circle())
//            }
//            .padding(.top, 20)
//        }
//        .background(Color.white)
//        .cornerRadius(20)
//        .padding()
//        .sheet(isPresented: $showCustomPicker) {
//            CustomTimePickerView { hour, minute in
//                let totalSeconds = hour * 3600 + minute * 60
//                if hour > 0 {
//                    selectedTimer = "\(hour)h \(minute)m"
//                } else {
//                    selectedTimer = "\(minute) min"
//                }
//                timerManager.startTimer(seconds: totalSeconds)
//                isPresented = false
//            }
//            .presentationDetents([.fraction(0.33)])
//        }
//    }
//
//    func secondsForOption(_ option: String) -> Int {
//        switch option {
//        case "5 min": return 5 * 60
//        case "10 min": return 10 * 60
//        case "15 min": return 15 * 60
//        case "20 min": return 20 * 60
//        case "25 min": return 25 * 60
//        case "30 min": return 30 * 60
//        case "45 min": return 45 * 60
//        case "1 hour": return 60 * 60
//        case "1.5 hour": return 90 * 60
//        case "2 hour": return 120 * 60
//        default: return 0
//        }
//    }
//}
//
//struct CustomTimePickerView: View {
//    var onSet: (Int, Int) -> Void
//    @Environment(\.dismiss) var dismiss
//    @State private var hour = 0
//    @State private var minute = 1
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack {
//                    Picker("Hour", selection: $hour) {
//                        ForEach(0..<24) { Text("\($0) h") }
//                    }
//                    .pickerStyle(WheelPickerStyle())
//                    Picker("Minutes", selection: $minute) {
//                        ForEach(0..<60) { Text("\($0) m") }
//                    }
//                    .pickerStyle(WheelPickerStyle())
//                }
//                .frame(height: 150)
//                Button("Set") {
//                    onSet(hour, minute)
//                    dismiss()
//                }
//                .disabled(hour == 0 && minute == 0)
//                .padding()
//            }
//            .frame(height: UIScreen.main.bounds.height / 3)
//            .navigationTitle("Select hours & minutes")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    SetTimerView(isPresented: .constant(true), selectedTimer: .constant("No timer"))
//}


import SwiftUI

struct CustomTimePickerView: View {
    var onSet: (Int, Int) -> Void
    @Environment(\.dismiss) var dismiss
    @Binding var showCustomPicker: Bool
    @Binding var isPresented: Bool
    @State private var hour = 0
    @State private var minute = 1

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24) { Text("\($0) h") }
                    }
                    .pickerStyle(WheelPickerStyle())
                    Picker("Minutes", selection: $minute) {
                        ForEach(0..<60) { Text("\($0) m") }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .frame(height: 150)
                Button("Set") {
                    onSet(hour, minute)
                    dismiss()
                    isPresented = false // Hide SetTimerView
                }
                .disabled(hour == 0 && minute == 0)
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height / 3)
            .navigationTitle("Select hours & minutes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCustomPicker = false
                        isPresented = true // Show SetTimerView again
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SetTimerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTimer: String
    @State private var showCustomPicker = false
    @EnvironmentObject var timerManager: TimerManager

    let timerOptions = [
        "No timer", "Custom", "5 min", "10 min", "15 min", "20 min", "25 min", "30 min", "45 min", "1 hour", "1.5 hour", "2 hour",
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Set timer")
                .font(.headline)
                .padding(.top, 24)
            List {
                ForEach(timerOptions, id: \.self) { option in
                    Button(action: {
                        if option == "Custom" {
                            showCustomPicker = true
                        } else {
                            selectedTimer = option
                            timerManager.startTimer(seconds: secondsForOption(option))
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedTimer == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .listStyle(PlainListStyle())
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(15)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.top, 20)
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
        .sheet(isPresented: $showCustomPicker) {
            CustomTimePickerView(
                onSet: { hour, minute in
                    let totalSeconds = hour * 3600 + minute * 60
                    if hour > 0 {
                        selectedTimer = "\(hour)h \(minute)m"
                    } else {
                        selectedTimer = "\(minute) min"
                    }
                    timerManager.startTimer(seconds: totalSeconds)
                },
                showCustomPicker: $showCustomPicker,
                isPresented: $isPresented
            )
            .presentationDetents([.fraction(0.33)])
        }
    }

    func secondsForOption(_ option: String) -> Int {
        switch option {
        case "5 min": return 5 * 60
        case "10 min": return 10 * 60
        case "15 min": return 15 * 60
        case "20 min": return 20 * 60
        case "25 min": return 25 * 60
        case "30 min": return 30 * 60
        case "45 min": return 45 * 60
        case "1 hour": return 60 * 60
        case "1.5 hour": return 90 * 60
        case "2 hour": return 120 * 60
        default: return 0
        }
    }
}
