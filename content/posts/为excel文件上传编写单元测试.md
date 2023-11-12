---
title: "为excel文件上传编写单元测试" # 标题
subtitle: "为excel文件上传编写单元测试" # 副标题
description: "" # 文章内容描述
date: 2023-11-12T20:51:13+08:00 # 时间
lastmod: 2023-11-12T20:51:13+08:00 # 上次修改时间
tags: ["python"] # 标签
categories: ["python"] # 分类
featuredImagePreview: "" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# 为excel文件上传编写单元测试

# 序列化器

```python
# -*- coding: utf-8 -*-
from django.utils.translation import gettext_lazy
from rest_framework import serializers


class ExcelSerializer(serializers.Serializer):
    file = serializers.FileField(
        label=gettext_lazy("excel文件"),
        required=True,
    )
```

# 模拟上传 excel 文件

1. 使用 `openpyxl` 在内存中生成 excel

   `pip install openpyxl`
2. 创建一个 `NamedTemporaryFile` 来存储 excel
3. 取 `NamedTemporaryFile` 并读入 `SimpleUploadedFile`
4. 将此 `SimpleUploadedFile` 传递到序列化程序中

```python
# -*- coding: utf-8 -*-
import copy
import tempfile
from io import BytesIO
from typing import List

import openpyxl
from django.core.files.uploadedfile import SimpleUploadedFile


class TempExcel:
    """生成一个内存中的临时excel"""

    suffix = ".xlsx"

    def __init__(self, titles: List[str], data: List[List[str]]):
        if len(titles) != len(data[0]):
            raise ValueError("标题和数据的列数不一致")
        self.data = copy.deepcopy(data)
        # 插入标题
        self.data.insert(0, titles)

    def __enter__(self):
        temp_file = tempfile.NamedTemporaryFile(delete=True, suffix=self.suffix)
        # 创建一个工作簿
        wb = openpyxl.Workbook()
        # 获取第一张表
        ws = wb.active
        # 插入数据
        rows = len(self.data)
        lines = len(self.data[0])
        for row in range(rows):
            for col in range(lines):
                ws.cell(row=row + 1, column=col + 1).value = self.data[row][col]
        # 存储到文件
        wb.save(filename=temp_file.name)
        byio = BytesIO(temp_file.read())
        self.file = SimpleUploadedFile(
            name=temp_file.name,
            content=byio.read(),
        )
        temp_file.close()
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.file.close()


if __name__ == "__main__":
    titles = ["MAC", "Accounts"]
    data = [["aa:bb:cc:dd:55:66", "aa,cc"], ["aa:cc:cc:dd:55:66", "bb,cc"]]
    with TempExcel(titles, data) as f:
        test_api(
            {
                "file": f,
            }
        )
```

# 参考

[Django - how to write test for DRF ImageField - Stack Overflow](https://stackoverflow.com/questions/56317854/django-how-to-write-test-for-drf-imagefield)

[how to unit test file upload in django - Stack Overflow](https://stackoverflow.com/questions/11170425/how-to-unit-test-file-upload-in-django)

‍