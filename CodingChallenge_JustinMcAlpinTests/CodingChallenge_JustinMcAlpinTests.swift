//
//  CodingChallenge_JustinMcAlpinTests.swift
//  CodingChallenge_JustinMcAlpin
//
//  Created by Admin on 8/5/20.
//

import XCTest
@testable import CodingChallenge_JustinMcAlpin

class CodingChallenge_JustinMcAlpinTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    func albumsDataHelper() -> Data {
        guard let path = Bundle(for: CodingChallenge_JustinMcAlpinTests.self).path(forResource: "top_albums", ofType: "json") else {
            fatalError()
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return data
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
 
    func test_CanDecode_AlbumsFeed() {
        // 1. get albums JSON from disk
        let data = albumsDataHelper()
        
        // 2. decode the feed
        let decoder = JSONDecoder()
        let model = try? decoder.decode(DataModel.self, from: data)
        
        // 3. ensure the albums were decoded correctly
        XCTAssertNotNil(model)
        XCTAssertEqual(model?.feed.results.count, 100)
    }
    
    func test_CanGetNil_WithNo_GenreStrings() {
        let album = Album(artistName: nil, name: nil, copyright: nil, artworkUrl100: nil, releaseDate: nil, genres: [], url: nil)

        XCTAssertNil(album.genresString)
    }
    
    func test_CanGetGenre_With_GenreStrings() {
        let genres = [Genre(name: "Punk Rock", genreId: "1")]
        let album = Album(artistName: nil, name: nil, copyright: nil, artworkUrl100: nil, releaseDate: nil, genres: genres, url: nil)
        
        XCTAssertNotNil(album.genresString)
        XCTAssertEqual(album.genresString, "Punk Rock")
    }
    
    func test_ListViewController_CanLoadFeed_WithinReasonableTime() {
        let listVC = ListViewController(service: MockNetworkService())
        
        listVC.downloadJSONFromURL()
        
        sleep(3)
        
        XCTAssertFalse(listVC.viewModel.viewModels.isEmpty)
        XCTAssertEqual(listVC.viewModel.viewModels.count, 100)
    }
    
    
    func test_ListViewController_CanFail_LoadingRequest() {
        let listVC = ListViewController(service: MockFailingNetworkService())
        
        listVC.downloadJSONFromURL()
        
        sleep(3)
        
        XCTAssert(listVC.viewModel.viewModels.isEmpty)
    }
    
    func test_DetailsViewController_ShowsCorrect_Information() {
        let detailsVC = DetailsViewController()
        let genres = [Genre(name: "Rap", genreId: "Rap")]
        let album = Album(artistName: "Machine Gun Kelly", name: "Bloody Valentine", copyright: "© 2020 Bad Boy/Interscope Records", artworkUrl100: nil, releaseDate: "2020-05-20", genres: genres, url: "https://www.machinegunkelly.com/")
        let albumViewModel = AlbumViewModel(album: album, service: MockFailingNetworkService())
        
        detailsVC.albumViewModel = albumViewModel
        detailsVC.loadViewIfNeeded()
        
        XCTAssertEqual(detailsVC.artistLabel.text, "Machine Gun Kelly")
        XCTAssertEqual(detailsVC.titleLabel.text, "Bloody Valentine")
        XCTAssertEqual(detailsVC.copyRightLabel.text, "© 2020 Bad Boy/Interscope Records")
        XCTAssertEqual(detailsVC.releaseDateLabel.text, "Release date: 2020-05-20")
        XCTAssertEqual(detailsVC.genreLabel.text, "Genre: Rap")
        XCTAssertEqual(detailsVC.albumViewModel?.url?.absoluteString, "https://www.machinegunkelly.com/")
    }
    
    func test_ViewModel_CanShowUnknowns() {
        let dumbAlbum = Album(artistName: nil, name: nil, copyright: nil, artworkUrl100: nil, releaseDate: nil, genres: [], url: nil)
        let albumViewModel = AlbumViewModel(album: dumbAlbum, service: MockFailingNetworkService())
        
        XCTAssertEqual(albumViewModel.name , "Unknown")
        XCTAssertEqual(albumViewModel.artist , "Unknown")
        XCTAssertNil(albumViewModel.albumArtURL)
        XCTAssertNil(albumViewModel.url)
        XCTAssertEqual(albumViewModel.copyright , "Unknown")
        XCTAssertEqual(albumViewModel.releaseDate , "Release date: Unknown")
        XCTAssertEqual(albumViewModel.genre , "Genre: Unknown")
    }

}
