//
//  Indicator.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }
}
