//
//  MenuItem.swift
//  morsenator
//
//  Created by Aaron Christopher Tanhar on 01/08/23.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct MenuItem<Content: View>: View {
    let width: Int
    let height: Int
    let title: String
    let image: String?
    var active: Bool = false
    var link: Content?

    var body: some View {
        NavigationLink(destination: link) {
            HStack {
                Image(image ?? "Clock").resizable().frame(width: 30, height: 30)
            }.frame(width: CGFloat(width), height: CGFloat(height))
                .background(.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
                .shadow(radius: 4, y: 3)
                .offset(x: -2)
            Spacer()
            Text(title).foregroundColor(active ? .white : .black)
                .fontWeight(.semibold)
            Spacer()
        }.frame(height: CGFloat(height)).background(active ? Color("StarCoin") : .white).roundedCorner(10, corners: [.bottomRight, .topRight])
            .roundedCorner(100, corners: [.bottomLeft, .topLeft])
            .shadow(radius: 4, y: 3)
            .disabled(active)
            .frame(width: nil)
    }
}

struct MenuItemButton: View {
    let width: Int
    let height: Int
    let title: String
    let image: String?
    var active: Bool = false

    var function: (() -> Void)?

    var body: some View {
        Button {
            if function != nil {
                function!()
            }
        } label: {
            HStack {
                Image(image ?? "Clock").resizable().frame(width: 30, height: 30)
            }.frame(width: CGFloat(width), height: CGFloat(height))
                .background(.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
                .shadow(radius: 4, y: 3)
                .offset(x: -2)
            Spacer()
            Text(title).foregroundColor(active ? .white : .black)
                .fontWeight(.semibold)
            Spacer()
        }.frame(width: nil, height: CGFloat(height)).background(active ? Color("StarCoin") : .white).roundedCorner(10, corners: [.bottomRight, .topRight])
            .roundedCorner(100, corners: [.bottomLeft, .topLeft])
            .shadow(radius: 4, y: 3)
            .disabled(active)
            .frame(width: nil)
    }
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MenuItem(width: 60, height: 60, title: "Working Hour & Interval", image: "Clock", active: true, link: ARHome())
            MenuItemButton(width: 60, height: 60, title: "Working Hour & Interval", image: "Clock", active: false)
        }
    }
}
