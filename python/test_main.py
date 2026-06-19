import pytest
from unittest.mock import patch
from datetime import datetime
from python.main import get_data, get_popularity


@pytest.fixture
def mock_response():
    return {"popularity": 75}


@patch("python.main.get_data")
def test_get_data(mock_get_data, mock_response):
    mock_get_data.return_value.json.return_value = mock_response
    client_id = "test_client_id"
    client_secret = "test_client_secret"
    song_id = "test_song_id"

    response = get_data(client_id, client_secret, song_id)
    assert response is not None
    assert "popularity" in response.json()


@patch("python.main.get_data")
def test_get_popularity(mock_get_data, mock_response):
    mock_get_data.return_value.json.return_value = mock_response

    client_id = "test_client_id"
    client_secret = "test_client_secret"
    song_id = "test_song_id"

    popularity = get_popularity(client_id, client_secret, song_id)
    assert popularity == 75


def test_data_format():
    timestamp = datetime.now().isoformat()
    assert timestamp.count("-") == 2
    assert "T" in timestamp