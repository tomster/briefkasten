# -*- coding: utf-8 -*-
from pytest import fixture
from os.path import dirname, join
from briefkasten.dropbox import generate_post_token, generate_drop_id


@fixture
def post_token(config):
    return generate_post_token(secret=config.registry.settings['post_secret'])


@fixture
def drop_id():
    return generate_drop_id()


@fixture(scope='function')
def dropbox_container(request, config):
    from briefkasten.dropbox import DropboxContainer
    dropbox_container = DropboxContainer(config.registry.settings)
    request.addfinalizer(dropbox_container.destroy)
    return dropbox_container


@fixture
def dropbox_without_attachment(dropbox_container, drop_id):
    return dropbox_container.add_dropbox(drop_id, message=u'Schönen guten Tag!')


@fixture
def attachment(testing):
    return testing.attachment_factory(
        filename=u'attachment.txt',
        file=open(join(dirname(__file__), 'attachment.txt'), 'r')
    )


@fixture
def dropbox(dropbox_container, drop_id, attachment):
    return dropbox_container.add_dropbox(
        drop_id,
        message=u'Schönen guten Tag!',
        attachments=[attachment],
    )
