from dotenv import load_dotenv
from os import getenv
from datetime import datetime
from requests import post, get

load_dotenv()
client_id = getenv("SPOTIFY_CLIENT_ID")
client_secret = getenv("SPOTIFY_CLIENT_SECRET")
data_file_name = "data.csv"
song_id = "2pXpURmn6zC5ZYDMms6fwa"


def get_data(client_id, client_secret, song_id):
    auth_response = post(
        "https://accounts.spotify.com/api/token",
        data={"grant_type": "client_credentials"},
        auth=(client_id, client_secret),
    )
    auth_response.raise_for_status()
    access_token = auth_response.json()["access_token"]

    headers = {"Authorization": f"Bearer {access_token}"}
    response = get(
        f"https://api.spotify.com/v1/tracks/{song_id}", headers=headers
    )
    response.raise_for_status()
    return response


def get_popularity(client_id, client_secret, song_id):
    response = get_data(
        client_id=client_id, client_secret=client_secret, song_id=song_id
    )
    song_info = response.json()
    popularity = song_info["popularity"]

    return popularity


def main():
    popularity = get_popularity(
        client_id=client_id,
        client_secret=client_secret,
        song_id=song_id,
    )
    timestamp_popularity = f"{datetime.now().isoformat()}, {popularity}\n"
    with open(data_file_name, "a") as file:
        file.write(timestamp_popularity)



if __name__ == "__main__":
    main()
