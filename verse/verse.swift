//
//  verse.swift
//  verse
//
//  Created by ajayprasanth on 20/01/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct verseEntryView : View {
    var entry: Provider.Entry
    @State var TextString: String = ""

    var body: some View {
        VStack {
            Text(TextString)
                .foregroundStyle(Color.white)
                .minimumScaleFactor(0.5)
                .onAppear{
                    if let groupDefaults = UserDefaults(suiteName: "group.com.bmrbibles.biblenewlivingtranslation") {
                        
                        TextString = groupDefaults.string(forKey: "VerseString") ?? "Thessalonians 5:16--18  Always be joyful.No matter what happens, always be thankful, for this is God's will for you who belong to Christ Jesus."
                        
                    }
                }
                
        }.ignoresSafeArea()
    }
}



struct QuizEntryView : View {
    var entry: Provider.Entry

    @State var choose: [String] = []
    
    @State var TextString: String = ""
    
    var body: some View {
        VStack {
            Text("Fill the blanks")
                .font(Font.subheadline.bold())
                .foregroundStyle(Color.white)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            
            Text(TextString)
                .foregroundStyle(Color.white)
                .minimumScaleFactor(0.5)
                .padding(.bottom)
                .onAppear{
                    if let groupDefaults = UserDefaults(suiteName: "group.com.bmrbibles.biblenewlivingtranslation") {
                        TextString = groupDefaults.string(forKey: "VerseQuiz") ?? "Thessalonians 5:16--18  Always be joyful.No matter what happens, always be thankful, for this is God's will for you who belong to Christ Jesus."
                        
                        TextString = keyseperator(question: TextString).0
                        choose = keyseperator(question: TextString).1
                    }
                }
            
            
            HStack{
                ForEach(0..<choose.count) { index in
                    Text(choose[index])
                        .foregroundStyle(Color(hex: "1C46B2"))
                        .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                        .background(Color.white)
                        .cornerRadius(3)
                }
            }
            
                
                
        }.ignoresSafeArea()
    }
}



struct verse: Widget {
    let kind: String = "verse"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                verseEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1C46B2"), Color(hex: "2FD3E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ).scaleEffect(3.5)
                    )
            } else {
                verseEntryView(entry: entry)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1C46B2"), Color(hex: "2FD3E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ).scaleEffect(3.5)
                    )
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}


struct QuoteWidget: Widget {
    let kind = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                QuizEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1C46B2"), Color(hex: "2FD3E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ).scaleEffect(3.5)
                    )
            } else {
                QuizEntryView(entry: entry)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "1C46B2"), Color(hex: "2FD3E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ).scaleEffect(3.5)
                    )
            }
        }
        .configurationDisplayName("Quote Widget")
        .description("Quote style widget")
        .supportedFamilies([.systemLarge])
    }
}




//#Preview(as: .systemSmall) {
//    verse()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}



import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24 & 0xFF,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


func keyseperator(question :String) -> (String,[String]) {
    var sometext = question.components(separatedBy: " ").filter { $0 != "" }.filter { $0 != " "}
    var AnswerKewords:[String] = []
    var ans:[String] = []
    var questionShow:String = ""
    
    for item in sometext {
        if AnswerKewords.contains(where: {$0.caseInsensitiveCompare(" \(item) ") == .orderedSame}) || AnswerKewords.contains(" \(item) ") {
            ans.append(" \(item) ")
        } else {
            AnswerKewords.append(" \(item) ")
        }
    }
    
    for item in ans {
        questionShow = question.replacingOccurrences(of: item, with: " ________ ")
    }
    
    
    
    return (questionShow, ans)
}
