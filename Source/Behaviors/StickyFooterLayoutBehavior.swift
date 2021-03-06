//
//  StickyFooterBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/2/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

/// A StickyFooterLayoutBehavior will stick certain bricks (based on the dataSource) on the bottom of its section
public class StickyFooterLayoutBehavior: StickyLayoutBehavior {

    override func updateStickyAttributesInCollectionView(collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        //Sort the attributes ascending
        stickyAttributes.sortInPlace { (attributesOne, attributesTwo) -> Bool in
            let maxYOne: CGFloat = attributesOne.originalFrame.maxY
            let maxYTwo: CGFloat = attributesTwo.originalFrame.maxY
            return maxYOne >= maxYTwo
        }
        super.updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    override func updateFrameForAttribute(inout attributes:BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {

        let isOnFirstSection = sectionAttributes == nil || sectionAttributes?.indexPath == NSIndexPath(forRow: 0, inSection: 0)
        let bottomInset = collectionViewLayout.collectionView!.contentInset.bottom

        if isOnFirstSection {
            collectionViewLayout.collectionView?.scrollIndicatorInsets.bottom = attributes.frame.height  + bottomInset
            attributes.frame.origin.y = contentBounds.maxY - attributes.frame.size.height - bottomInset
        } else {
            let y = contentBounds.maxY - attributes.frame.size.height - bottomInset
            attributes.frame.origin.y = min(y, attributes.originalFrame.origin.y)
        }

        if lastStickyFrame.size != CGSizeZero {
            attributes.frame.origin.y = min(lastStickyFrame.minY - attributes.frame.height, attributes.originalFrame.origin.y)
        }

        return !isOnFirstSection
    }
}
