//
//  FeedView.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import SwiftUI

enum FeedFilter: String, CaseIterable {
    case everyone = "Everyone"
    case friends = "Friends Only"
    
    var icon: String {
        switch self {
        case .everyone:
            return "globe"
        case .friends:
            return "person.2.fill"
        }
    }
}

struct FeedView: View {
    @StateObject var feedViewModel: FeedViewModel
    @State private var selectedFilter: FeedFilter = .everyone
    @State private var isFilterExpanded = false
    @State private var scrollOffset: CGFloat = 0
    
    init(viewModel: FeedViewModel = FeedViewModel()) {
        _feedViewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header with title and filter
                    headerSection
                        .background(Color(.systemGroupedBackground))
                        .opacity(headerOpacity)
                        .scaleEffect(headerScale, anchor: .top)
                        .clipped()
                    
                    // Content
                    LazyVStack(spacing: 12) {
                        ForEach(feedViewModel.posts, id: \.id) { post in
                            PostView(post: post)
                        }
                    }
                    .padding(.top, 8)
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: scrollGeometry.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .refreshable {
                switch selectedFilter {
                case .everyone:
                    await feedViewModel.refreshPostsAsync(fetchingFriendsPosts: false)
                case .friends:
                    await feedViewModel.refreshPostsAsync(fetchingFriendsPosts: true)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            switch selectedFilter {
            case .everyone:
                feedViewModel.fetchAllPosts()
            case .friends:
                feedViewModel.fetchFriendsPosts()
            }
        }
    }
    
    private var headerOpacity: Double {
        let fadeStart: CGFloat = 0
        let fadeEnd: CGFloat = -80
        
        if scrollOffset >= fadeStart {
            return 1.0
        } else if scrollOffset <= fadeEnd {
            return 0.0
        } else {
            return Double((scrollOffset - fadeEnd) / (fadeStart - fadeEnd))
        }
    }
    
    private var headerScale: CGFloat {
        let scaleStart: CGFloat = 0
        let scaleEnd: CGFloat = -100
        let minScale: CGFloat = 0.8
        
        if scrollOffset >= scaleStart {
            return 1.0
        } else if scrollOffset <= scaleEnd {
            return minScale
        } else {
            let progress = (scrollOffset - scaleEnd) / (scaleStart - scaleEnd)
            return minScale + (1.0 - minScale) * progress
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Feed")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            // Filter Toggle Button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isFilterExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: selectedFilter.icon)
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(selectedFilter.rawValue)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12, weight: .medium))
                            .rotationEffect(.degrees(isFilterExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isFilterExpanded)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 0.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Expandable Filter Options
            if isFilterExpanded {
                VStack(spacing: 6) {
                    ForEach(FeedFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                                isFilterExpanded = false
                            }
                            applyFilter(filter)
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: filter.icon)
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 18)
                                
                                Text(filter.rawValue)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                
                                Spacer()
                                
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 11, weight: .bold))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedFilter == filter ?
                                          Color.accentColor : Color(.tertiarySystemGroupedBackground))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
            
            // Separator
            Rectangle()
                .fill(Color(.separator).opacity(0.6))
                .frame(height: 0.5)
                .padding(.top, isFilterExpanded ? 12 : 6)
                .padding(.bottom, 2)
        }
    }
    
    private func applyFilter(_ filter: FeedFilter) {
        switch filter {
        case .everyone:
            feedViewModel.fetchAllPosts()
        case .friends:
            feedViewModel.fetchFriendsPosts()
        }
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    FeedView()
}
