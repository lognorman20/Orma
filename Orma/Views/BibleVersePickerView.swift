import SwiftUI

// MARK: - Preview and Example Usage
struct BibleVersePickerView: View {
    @State var book: String
    @State var chapter: Int
    @State var verseStart: Int
    @State var verseEnd: Int
    @FocusState private var isBookFocused: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Book", text: $book)
                    .border(.primary)
                    .padding()
                    .font(.headline)
                    .focused($isBookFocused)
                    .onSubmit {
                        isBookFocused = false
                    }

                if isBookFocused && !book.isEmpty {
                    let matches = BibleData.bibleVerseMap.keys
                        .filter { $0.localizedCaseInsensitiveContains(book) }
                        .sorted { a, b in
                            let aExact =
                                a.localizedCaseInsensitiveCompare(book)
                                == .orderedSame
                            let bExact =
                                b.localizedCaseInsensitiveCompare(book)
                                == .orderedSame
                            if aExact != bExact {
                                return aExact  // exact matches come first
                            }
                            return a < b  // otherwise alphabetical
                        }

                    if !matches.isEmpty {
                        List(matches, id: \.self) { match in
                            Text(match)
                                .onTapGesture {
                                    book = match
                                    isBookFocused = false
                                }
                        }
                        .frame(maxHeight: 150)
                    }
                }
            }

            TextField("chapter", value: $chapter, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .border(.primary)
                .font(.headline)
                .padding()
                .onChange(of: chapter) { _, newValue in
                    if newValue < 1 { chapter = 1 }
                    if let maxChapter = BibleData.bibleVerseMap[book]?.keys
                        .max(),
                        newValue > maxChapter
                    {
                        chapter = maxChapter
                    }
                }

            TextField(
                "verse start", value: $verseStart, formatter: NumberFormatter()
            )
            .keyboardType(.numberPad)
            .border(.primary)
            .font(.headline)
            .padding()
            .onChange(of: verseStart) { _, newValue in
                if newValue < 1 { verseStart = 1 }
                if let maxVerse = BibleData.getMaxVerses(
                    book: book, chapter: chapter),
                    newValue > maxVerse
                {
                    verseStart = maxVerse
                }
            }

            TextField(
                "verse end", value: $verseEnd, formatter: NumberFormatter()
            )
            .keyboardType(.numberPad)
            .border(.primary)
            .font(.headline)
            .padding()
            .onChange(of: verseEnd) { _, newValue in
                if newValue < 1 { verseEnd = 1 }
                if let maxVerse = BibleData.getMaxVerses(
                    book: book, chapter: chapter),
                    newValue > maxVerse
                {
                    verseEnd = maxVerse
                }
            }

            Button("Validate Verse") {
                switch BibleData.validateVerse(
                    book: book, chapter: chapter, verse: verseEnd)
                {
                case .success:
                    print("valid bruv")
                    break
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var book: String = ""
    @Previewable @State var chapter: Int = 4
    @Previewable @State var verseStart: Int = 3
    @Previewable @State var verseEnd: Int = 5
    BibleVersePickerView(
        book: book, chapter: chapter, verseStart: verseStart, verseEnd: verseEnd
    )
}
