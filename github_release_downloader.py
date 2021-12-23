#!/usr/bin/env python3

import argparse
import json
import requests
import logging
import re
import zipfile
import os
import sys

log = logging.getLogger("GithubReleaseDownloader")
log.addHandler(logging.StreamHandler())
log.setLevel(logging.WARNING)

GITHUB_RELEASE_URL = "https://api.github.com/repos/%s/releases/latest"
VALID_JSON_KEYS = ('project_slug', 'match', 'destination', 'api_info_only')


def get_release_api_info(slug, session=None):
    s = session if session is not None else requests.session()
    url = GITHUB_RELEASE_URL % slug
    r = s.get(url)
    if r.status_code != 200:
        log.error("Response %d for %s", r.status_code, url)
        raise Exception(f"Failed to get json data for {slug}")

    dat = json.loads(r.content)
    return dat


def get_latest_asset_url(slug, match=None, session=None):
    dat = get_release_api_info(slug, session)
    assets = dat['assets']
    if not assets:
        raise Exception(f"Release for {slug} has no assets")

    if len(assets) == 1:
        return assets[0]['browser_download_url']

    if len(assets) > 1 and match is None:
        raise Exception(f"There are {len(assets)} assets and no "
                        "match string, need a string to match "
                        "to know which to download")

    matched_assets = [i for i in assets if
                      re.search(match, i['browser_download_url'])
                      is not None]

    if not matched_assets:
        raise Exception(f"{slug} had no matching assets")

    if len(matched_assets) > 1:
        log.warning("More than one matching asset for %s "
                    "defaulting to first", slug)

    return matched_assets[0]['browser_download_url']


def download_media(url, destination=None, session=None):
    """url: url to download from
    destination: file path to save to"""
    log.debug("fetching from %s", url)
    basename = os.path.basename(url)
    if destination is not None:
        if os.path.isdir(destination):
            destination = os.path.join(destination, basename)
    else:
        destination = basename

    os.system(f"curl -L '{url}' -o '{destination}'")
    # s = session if session is not None else requests.session()
    # r = s.get(url, stream=True)
    # with open(destination, 'wb') as f:
    #     for chunk in r.iter_content(chunk_size=1024):
    #         if chunk:
    #             f.write(chunk)

    return destination


def parse_args(arguments):
    parser = argparse.ArgumentParser()
    # parser.add_subparsers(dest="subparser")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-s", "--project-slug",
                       help="Project Slug")
    group.add_argument("-j", "--json", type=os.path.expanduser,
                       help="json file describing a series of "
                       "downloads to perform. Structure must be a "
                       "list of dicts, and dicts must contain only "
                       "values in %s as keys" % str(VALID_JSON_KEYS))
    parser.add_argument("-d", "--destination",
                        type=os.path.expanduser,
                        help="path to save file to. If not "
                        "provided or if provided path is a "
                        "directory, filename is used")
    parser.add_argument("-m", "--match",
                        help="Match string to select a specific asset")
    parser.add_argument("-a", "--api-info-only", default=False,
                        action="store_true",
                        help="Print the api-data for the given "
                        "slug out and return")
    # parser.add_argument("-i", "--install",
    #                     help="Extract downloaded file to this "
    #                     "location. Requires permissions in "
    #                     "target directory")
    # parser.add_argument("--strip-components", default=0, type=int,
    #                     help="If unzipped, strip NUMBER of "
    #                     "leading components from file names on "
    #                     "extraction")
    # parser.add_argument("--rename",
    #                     help="rename top level directory if "
    #                     "unzipped")
    parser.add_argument("--debug", action="store_true",
                        default=False,
                        help="Enable debug logging")
    args = parser.parse_args(arguments)
    log.setLevel(logging.DEBUG if args.debug is True
                 else logging.WARNING)
    # if args.json is None and args.project_slug is None:
    #     raise argparse.ArgumentError(args.project_slug,
    #                                  "Either json or slug must be specified")

    return args, parser


def handle_single_slug_arg(project_slug, match=None, destination=None,
                           api_info_only=False):
    if api_info_only is True:
        dat = get_release_api_info(project_slug)
        return json.dumps(dat, indent=2)
    else:
        url = get_latest_asset_url(project_slug, match)
        filename = download_media(url, destination)
        return filename


def handle_json_file(args):
    with open(args.json, "r") as f:
        dat = json.load(f)
    if (not isinstance(dat, list)) or any(bool(not isinstance(i, dict))
                                          for i in dat) is True:
        raise Exception("Json file must be a list of dicts")

    # strip out invalid args
    valid_kwargs = []
    for i, entry in enumerate(dat):
        valid = True
        for k in entry.keys():
            if k not in VALID_JSON_KEYS:
                log.warning("JSON file entry %d contains a key value %s that "
                            "is invalid", i, k)
                valid = False
                break
        if valid is True:
            valid_kwargs.append(entry)

    for kwargs in valid_kwargs:
        ret = handle_single_slug_arg(**kwargs)
        print(ret)


if __name__ == "__main__":
    args, parser = parse_args(sys.argv[1:])

    if args.project_slug is not None:
        res = handle_single_slug_arg(args.project_slug,
                                     args.match,
                                     args.destination,
                                     args.api_info_only)
        print(res)
    else:
        handle_json_file(args)

