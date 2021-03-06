//
//  BrickSectionDataSource.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation


// MARK: - Convenience methods for a BrickSection
extension BrickSection {

    /// Number Of Sections
    func numberOfSections(in collection: CollectionInfo) -> Int {
        invalidateIfNeeded(in: collection)
        return sectionCount
    }

    func numberOfBricks(in collection: CollectionInfo) -> Int {
        return bricks.reduce(0) { $0.0 + $0.1.count(for: collection) }
    }

    private func brickSection(for section: Int, in collection: CollectionInfo) -> BrickSection? {
        if let indexPath = sectionIndexPaths[collection]?[section] {
            return brick(at: indexPath, in: collection) as? BrickSection
        }

        return nil
    }

    /// Return number of items that are in a given section
    ///
    /// - parameter section: Section
    ///
    /// - returns: The number of items in the given section
    func numberOfItems(in section: Int, in collection: CollectionInfo) -> Int {
        invalidateIfNeeded(in: collection)

        guard section > 0 else {
            return 1
        }

        guard let brickSection = brickSection(for: section, in: collection) else {
            return 0
        }

        return brickSection.numberOfBricks(in: collection)
    }

    internal func brickAndIndex(at indexPath: NSIndexPath, in collection: CollectionInfo) -> (Brick, Int)? {
        invalidateIfNeeded(in: collection)

        if indexPath.section == 0 {
            return (self, 0)
        }

        guard let section = brickSection(for: indexPath.section, in: collection) else {
            return nil
        }

        var index = 0
        for brick in section.bricks {
            if indexPath.item < index + brick.count(for: collection) {
                return (brick, indexPath.item - index)
            }
            index += brick.count(for: collection)
        }

        return nil
    }

    func brick(at indexPath: NSIndexPath, in collection: CollectionInfo) -> Brick? {
        return brickAndIndex(at: indexPath, in: collection)?.0
    }

    func index(at indexPath: NSIndexPath, in collection: CollectionInfo) -> Int? {
        return brickAndIndex(at: indexPath, in: collection)?.1
    }

    func indexPathForSection(section: Int, in collection: CollectionInfo) -> NSIndexPath? {
        return sectionIndexPaths[collection]?[section]
    }

    /// Get the indexPaths for a brick with a certain identifier
    ///
    /// - parameter identifier: Identifier
    /// - parameter index:      Index
    ///
    /// - returns: an array of identifiers
    func indexPathsForBricksWithIdentifier(identifier: String, index: Int? = nil, in collection: CollectionInfo) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []

        for section in 0..<numberOfSections(in: collection) {
            for item in 0..<numberOfItems(in: section, in: collection) {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let foundBrickWithIndex = brickAndIndex(at: indexPath, in: collection)! //We can safely unwrap, because this indexPath must exist
                if foundBrickWithIndex.0.identifier == identifier {
                    if let index = index where foundBrickWithIndex.1 != index {
                        continue
                    }
                    indexPaths.append(indexPath)
                }
            }
        }

        return indexPaths
    }

    /// Gets the section index of a given indexPath
    ///
    /// - parameter indexPath: IndexPath
    ///
    /// - returns: Optional index
    func sectionIndexForSectionAtIndexPath(indexPath: NSIndexPath, in collection: CollectionInfo) -> Int? {
        let sectionIndexPaths = invalidateIfNeeded(in: collection)

        guard let section = sectionIndexPaths.allKeysForValue(indexPath).first else {
            return nil
        }

        return section
    }

    /// A Dictionary with the item-count of each section
    internal func currentSectionCounts(in collection: CollectionInfo) -> [Int: Int] {
        var sectionCounts: [Int: Int] = [:]

        for section in 0..<numberOfSections(in: collection) {
            sectionCounts[section] = numberOfItems(in: section, in: collection)
        }

        return sectionCounts
    }

}
