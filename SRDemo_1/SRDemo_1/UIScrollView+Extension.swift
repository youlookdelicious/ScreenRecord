//
//  UIScrollView+Extension.swift
//  ZhSwiftDemo
//
//  Created by Zhuang on 2018/8/10.
//  Copyright © 2018年 Zhuang. All rights reserved.
//  UITableView/UICollectionView 注册 cell

import UIKit


extension UITableView {
    
    /// 注册 cell
    func cm_register<T: UITableViewCell>(cell: T.Type) where T: ReusableView {
        if let nib = T.nib  {
            register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 取缓存池的cell
    func cm_dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
}

extension UICollectionView {
    
    /// 注册cell
    func cm_register<T: UICollectionViewCell>(cell: T.Type) where T: ReusableView {
        if let nib = T.nib {
            register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            register(cell, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 注册头部
    func cm_registerSupplementaryHeaderView<T: UICollectionReusableView>(reusableView: T.Type) where T: ReusableView {
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// 获取cell
    func cm_dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    /// 获取可重用的头部
    func cm_dequeueReusableSupplementaryHeaderView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
}

