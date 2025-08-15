import SwiftUI

// MARK: - Preview and Example Usage
struct BibleVersePickerView: View {
    @Binding var book: String
    @Binding var chapter: Int
    @Binding var verseStart: Int
    @Binding var verseEnd: Int
    @FocusState private var isBookFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Book Selection with Autocomplete
            VStack(alignment: .leading, spacing: 8) {
                Text("Book")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 0) {
                    TextField("Search for a book...", text: $book)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isBookFocused
                                        ? Color.accentColor : Color.clear,
                                    lineWidth: 2)
                        )
                        .focused($isBookFocused)
                        .onSubmit {
                            isBookFocused = false
                        }

                    if isBookFocused && !book.isEmpty {
                        let matches = BibleData.bibleVerseMap.keys
                            .filter {
                                $0.localizedCaseInsensitiveContains(book)
                            }
                            .sorted { a, b in
                                let aExact =
                                    a.localizedCaseInsensitiveCompare(book)
                                    == .orderedSame
                                let bExact =
                                    b.localizedCaseInsensitiveCompare(book)
                                    == .orderedSame
                                if aExact != bExact {
                                    return aExact
                                }
                                return a < b
                            }

                        if !matches.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(matches.prefix(5), id: \.self) {
                                    match in
                                    HStack {
                                        Text(match)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    .onTapGesture {
                                        book = match
                                        isBookFocused = false
                                    }

                                    if match != matches.prefix(5).last {
                                        Divider()
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(
                                color: .black.opacity(0.1), radius: 8, x: 0,
                                y: 4
                            )
                            .padding(.top, 4)
                        }
                    }
                }
            }

            // Chapter and Verse Inputs
            HStack(spacing: 16) {
                // Chapter Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chapter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    TextField(
                        "1", value: $chapter, formatter: NumberFormatter()
                    )
                    .keyboardType(.numberPad)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .onChange(of: chapter) { _, newValue in
                        if newValue < 1 { chapter = 1 }
                        if let maxChapter = BibleData.bibleVerseMap[book]?.keys
                            .max(),
                            newValue > maxChapter
                        {
                            chapter = maxChapter
                        }
                    }
                }

                // Verse Range Inputs
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verses")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 8) {
                        TextField(
                            "1", value: $verseStart,
                            formatter: NumberFormatter()
                        )
                        .keyboardType(.numberPad)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: verseStart) { _, newValue in
                            if newValue < 1 { verseStart = 1 }
                            if let maxVerse = BibleData.getMaxVerses(
                                book: book, chapter: chapter),
                                newValue > maxVerse
                            {
                                verseStart = maxVerse
                            }
                        }

                        Text("to")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField(
                            "1", value: $verseEnd, formatter: NumberFormatter()
                        )
                        .keyboardType(.numberPad)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: verseEnd) { _, newValue in
                            if newValue < 1 { verseEnd = 1 }
                            if let maxVerse = BibleData.getMaxVerses(
                                book: book, chapter: chapter),
                                newValue > maxVerse
                            {
                                verseEnd = maxVerse
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    BibleVersePickerView(
        book: .constant("Genesis"),
        chapter: .constant(4),
        verseStart: .constant(3),
        verseEnd: .constant(5)
    )
}
