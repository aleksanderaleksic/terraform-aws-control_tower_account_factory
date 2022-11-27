# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
import datetime
import inspect
import logging
import time
import uuid
from typing import Any, Dict, TypedDict, List

from boto3.session import Session

logger = logging.getLogger()
logger.setLevel(level=logging.INFO)


class LayerBuildStatus(TypedDict):
    Status: int


def lambda_handler(event: Dict[str, Any], context: Dict[str, Any]) -> LayerBuildStatus:
    session = Session()
    try:
        client = session.client("stepfunctions")
        stateMachineArn = event['stateMachineArn']
        aftLambdaLayerHash = event['aftLambdaLayerHash']

        runningStateMachineCount = None
        while runningStateMachineCount != 0:
            runningStateMachines = client.list_executions(
                stateMachineArn=stateMachineArn,
                statusFilter='RUNNING'
            )
            runningStateMachineCount = len(runningStateMachines['executions'])
            time.sleep(10)

        succeededStateMachines = client.list_executions(
            stateMachineArn=stateMachineArn,
            statusFilter='SUCCEEDED'
        )

        executionArn = None
        if len(succeededStateMachines['executions']) > 0:
            for succeededExecution in succeededStateMachines['executions']:
                arn = succeededExecution['executionArn']
                execution = client.describe_execution(
                    executionArn=arn
                )
                if aftLambdaLayerHash in execution['input']:
                    executionArn = arn

        if executionArn is None:
            executionStart = client.start_execution(
                stateMachineArn=stateMachineArn,
                name=str(uuid.uuid1()),
                input=f'"buildHash": "{aftLambdaLayerHash}"'
            )
            executionArn = executionStart['executionArn']

        while True:
            execution = client.describe_execution(
                executionArn=executionArn
            )
            if execution['status'] == 'SUCCEEDED':
                logger.info(f"Build execution {executionArn} completed successfully")
                return {"Status": 200}
            time.sleep(10)

    except Exception as error:
        message = {
            "FILE": __file__.split("/")[-1],
            "METHOD": inspect.stack()[0][3],
            "EXCEPTION": str(error),
        }
        logger.exception(message)
        raise
